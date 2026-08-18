# ARCHITECTURE — تقرير التحليل المعماري لتطبيق Chat App

**الحالة:** مستند تحليل وتخطيط فقط (لا يتضمن تعديل كود)

## القرارات المعتمدة

- إضافة `get_it` لإدارة حقن التبعيات (Dependency Injection).
- استخدام `dartz` مع سلسلة `Failure` للتعامل مع الأخطاء (`Either<Failure, Type>`).
- توحيد إدارة الحالة على `flutter_bloc` وإلغاء مكتبة `provider`.
- طبقة الـ Domain لا تعتمد على الـ Data ولا على `dart:io` (الصور تُمرَّر كـ `Uint8List`).

---

## 1. نظرة عامة على البنية الحالية

```
lib/
├── core/          (provider, supabase_config, utils/widgets, utils/services)
└── features/
    ├── auth/      (data: datasources/remote, models, repositories | domain: entities, repositories, usecases | presentation: manager/bloc, screens)
    ├── chat/      (نفس الهيكل)
    ├── contact/
    ├── group/
    ├── setting/
    ├── home/      (presentation only — screens/widgets)
    └── navigation/ (presentation only)
```

الملفات موزّعة على `data/domain/presentation` تقريباً، والـ use cases والـ abstract repositories موجودة. البنية "تشبه" Clean Architecture شكلياً لكنها تخترقها فعلياً في عدة مواضع حاسمة.

---

## 2. النتائج التفصيلية

### 🔴 A. انتهاك قاعدة التبعية (Dependency Rule) — الـ Domain يعتمد على الـ Data

الـ domain يجب ألا يستورد أي شيء من الـ data أو flutter. الحالة الحالية:

| الملف | المشكلة |
|---|---|
| `lib/features/chat/domain/repositories/chat_repository.dart` | يستورد `UserModel` من `auth/data/models` |
| `lib/features/chat/domain/usecases/send_message_use_case.dart` | `UserModel` داخل الـ domain |
| `lib/features/chat/domain/usecases/send_image_use_case.dart` | `UserModel` |
| `lib/features/group/domain/repositories/group_repository.dart` | يستورد `ChatGroupModel` |
| `lib/features/group/domain/usecases/send_group_message_use_case.dart` | `ChatGroupModel` |

**الأثر:** قاعدة التبعية مكسورة؛ أي تغيير في النماذج يفرض تعديل الـ domain. ولهذا السبب الـ Entities الثلاثة (`UserEntity`, `ChatRoomEntity`, `GroupEntity`) غير مستخدمة نهائياً — كيانات "ميتة".

**الحل:** الـ repositories تتعامل مع Entities فقط، والنماذج تقوم بالـ mapping عبر `toEntity()/fromEntity()`.

### 🔴 B. الـ Presentation يلمس Firebase مباشرة

أخطر انحراف؛ الـ presentation يعرض حالة فقط لكنه هنا ينفّذ الاستعلامات بنفسه:

- `chats_home_screen.dart` — stream غرف المستخدم مباشرة
- `chat_screen.dart` — حالة الأونلاين + قراءة الرسائل مباشرة
- `group_screen.dart` — أعضاء المجموعة + رسائل المجموعة مباشرة
- `groups_home_screen.dart` — قائمة المجموعات مباشرة
- `contact_home_screen.dart` — تحميل الجهات (StreamBuilder متداخل)
- `create_group_screen.dart` / `edit_group_screen.dart` — جهات المستخدم مباشرة
- `chat_card.dart` — معلومات المستخدم + عداد الغير مقروء مباشرة
- `group_message_card.dart` — اسم المرسل مباشرة
- `setup_profile_screen.dart` — `FirebaseAuth.instance.updateDisplayName` مباشرة
- `settings_home_screen.dart` — `FirebaseAuth.instance.signOut()` مباشرة

**الأثر:** استحالة اختبار الشاشات، صعوبة استبدال المصدر، وانتشار أي تغيير في مخطط Firestore في كل الـ widgets. لا يوجد أي use case أو BLoC للقراءة/الاشتراك.

**الحل:** كل القراءة تمر عبر use cases تُرجع `Stream<Entity>`، والشاشات تستهلك حالة الـ BLoCs فقط.

### 🔴 C. غياب Dependency Injection

النمط المتكرر في كل الـ BLoCs — إنشاء السلسلة الكاملة داخل كل معالج حدث:

```dart
// auth_bloc.dart (مكرر في كل الأحداث)
final usecase = SignInUsecase(
  repository: AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSourceImp()),
);
```

نفس النمط في `chat_message_bloc`, `chat_room_bloc`, `group_bloc`, `chat_group_message_bloc`, `contact_bloc`, `profile_bloc`.

**الأثر:** كائنات جديدة تُنشأ مع كل حدث، ولا يمكن حقن نسخ وهمية، وبالتالي لا يوجد اختبار ممكن.

**الحل:** حقن الـ use cases عبر الـ constructor وتسجيلها في `get_it`.

### 🔴 D. تسريب ذاكرة + BLoC-per-message

- `chat_message_card.dart` و `group_message_card.dart`: كل رسالة في القائمة تنشئ `BlocProvider(create: () => ChatMessageBloc())` داخل `build` → مع 100 رسالة = 100 BLoC نشط.
- `nav_main_screen.dart` و `settings_home_screen.dart`: `AuthBloc()` يُنشأ كـ field ولا يُغلق أبداً.
- `nav_main_screen.dart`: `SystemChannels.lifecycle` handler يشتري من BLoC جديد.

**الحل:** BLoC واحد خاص بكل شاشة، وقراءة الرسائل تتم عبر أحداث على ذلك الـ BLoC؛ والـ auth عبر BLoC واحد مشترك من `get_it`.

### 🔴 E. أمني — أسرار في الكود والـ bundle

- `lib/core/supabase_config.dart` — مفتاح Supabase كـ constant ثابت.
- `pubspec.yaml` — `google_services/notification_key.json` (حساب خدمة FCM كامل) مُضمَّن كأصل داخل التطبيق وينزل لجميع الأجهزة. يجب أن يبقى في خادم؛ إرسال الإشعارات يجب أن يتم من backend (Cloud Function مثلاً).

### 🟠 F. God Object `ProviderApp`

`lib/core/provider/provider.dart` يخلط مسؤوليات منفصلة:

1. إدارة الثيم/اللون (SharedPreferences)
2. تحميل بيانات المستخدم من Firestore
3. إرسال FCM token للمستخدم
4. الاحتفاظ بكائنات Firebase

**الحل:** فصل إلى `ThemeCubit` + `SessionCubit` مع إلغاء مكتبة `provider`.

### 🟠 G. جودة الكود والتسميات

- تسميات غير متسقة: `AuthRepositoryImpl` مقابل `ChatRepositoryImp` مقابل `GroupRepositoryImp` — توحيد `*Impl` أو `*Imp`.
- بنية المجلدات غير موحّدة: `auth/data/datasources/remote/` مقابل `contact/data/datasource`, `chat/data/datasource`, `group/data/datasource`, `setting/data/datasoure` (غلط إملائي).
- **Duplication**: `MessageModel` و `GroupMessageModel` متطابقان حرفياً؛ ومنطق `ChatRemoteDataSourceImp` و `GroupRemoteDataSourceImp` متقارب.
- `notification_services.dart` — `catch (e) {}` يبتلع الأخطاء صامتاً.
- `sendImage` / `updateProfileImage` في الـ datasources: `catch (e) { print(...); return null; }` رغم أن التوقيع `Future<void>` — إخفاء فشل فعلي.
- `UserModel.fromJson` — `json['id'] ?? '' as String?`: الـ cast يقع على `''` فقط وليس النتيجة الكاملة (مشكلة أسبقية operator).
- `List? members` بدون typing — يجب `List<String>`.
- تواريخ `createdAt` مخزنة كـ `String` (epoch ms) بدل `Timestamp` — فقدان دعم المناطق الزمنية.
- أخطاء إملائية: `Loadding`, `Succsfully`, `datasoure`, `createCharRoom`.
- رسائل النجاح/الخطأ hard-coded في كل BLoC/شاشة.
- `main.dart` — كل التهيئة (Supabase, Firebase, FCM) inline مع `print` للـ token.
- لا يوجد أي اختبار (`test/widget_test.dart` افتراضي).

---

## 3. البنية المستهدفة (المقترحة)

```
lib/
├── core/
│   ├── di/injection.dart               # get_it Service Locator
│   ├── error/failure.dart              # Failure hierarchy
│   ├── usecases/usecase.dart           # abstract UseCase<Type, Params>
│   ├── network/                        # اتصالات مشتركة (اختياري)
│   └── utils/ (widgets, constants...)
├── features/<feature>/
│   ├── data/
│   │   ├── datasources/                # اسم موحّد
│   │   ├── models/                     # مع toEntity()/fromEntity()
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/               # تعاقدات على Entities فقط
│   │   └── usecases/                   # UseCase<Type, Params> مع Either<Failure, Type>
│   └── presentation/
│       ├── bloc/ (أو cubit/)           # حقن usecases عبر constructor
│       └── screens/ widgets/
```

**قواعد ملزمة:**

- الـ Domain لا يستورد نماذج (`*Model`) ولا مكتبات خارجية (`dart:io`, firebase, supabase).
- الصور تُمرَّر عبر الـ layers كـ `Uint8List` أو كيان قيمة `ImageData` بدلاً من `File`.
- كل BLoC يعلن `Either<Failure, Type>` من الـ use case ويعرض `Failure` كرسالة ثابتة.
- الشاشات لا تلمس Firebase إطلاقاً.

---

## 4. خارطة الطريق التفصيلية

### المرحلة 0 — الأساسات
1. إضافة `get_it`, `dartz` للـ pubspec.
2. `core/error/failure.dart`: `Failure` (abstract) + `ServerFailure`, `CacheFailure`, `NetworkFailure`.
3. `core/usecases/usecase.dart`: `abstract class UseCase<Type, Params>` + `NoParams`.
4. `core/di/injection.dart`: تسجيل كل الـ datasources → repositories → usecases → blocs.
5. حذف `core/provider/provider.dart` و `provider` من pubspec، واستبداله بـ `ThemeCubit` + `SessionCubit`.

### المرحلة 1 — إصلاح الـ Domain
1. إنشاء `MessageEntity`, `GroupMessageEntity` و `MembershipEntity` المفقودة.
2. `UserModel.toEntity()/fromEntity()` (ونفس الشيء لـ ChatRoomModel, ChatGroupModel, MessageModel, GroupMessageModel).
3. تعديل تعاقدات الـ repositories لتأخذ Entities وترجع `Either<Failure, Type>`.
4. تعديل كل الـ use cases لتأخذ Entities + `Uint8List` للصور، وإزالة كل استيرادات `auth/data` و `group/data` من الـ domain.
5. توحيد التسميات إلى `*Impl` + توحيد مجلدات `datasources`.

### المرحلة 2 — إصلاح الـ Data
1. إضافة use cases/طرق repositories للقراءة: `GetChatsStream`, `GetMessagesStream(roomId)`, `GetUsersStream`, `GetGroupStream`, `GetGroupMessagesStream`, `GetOnlineStatusStream`, `GetContactsStream`.
2. الـ datasources تُرجع `Stream<Entity>` من Firestore (بعد mapping).
3. إزالة منطق الإشعارات من الـ datasources → حقن `PushNotificationService` (interface) في repository.
4. إزالة `notification_key.json` من pubspec assets وإرسال الإشعارات من backend.

### المرحلة 3 — إصلاح الـ Presentation
1. استبدال كل `FirebaseFirestore.instance` / `FirebaseAuth.instance` في الشاشات بـ `BlocBuilder/BlocListener` على الـ BLoCs الجديدة.
2. نقل منطق `updateDisplayName` و `signOut` إلى use cases داخل `AuthBloc` / `SessionCubit`.
3. إزالة BLoC-per-message: قراءة الرسالة تتم عبر حدث على BLoC واحد خاص بالشاشة.

### المرحلة 4 — إصلاح الـ BLoCs
1. `AuthBloc` واحد مشترك من `get_it` (لا إنشاءات في الـ widgets) مع `close()` عند الحاجة.
2. `ChatMessageBloc` / `GroupBloc` / ... تأخذ الـ use cases عبر الـ constructor.
3. الـ `Failure` تُعرَض كرسائل، وكل رسالة ثابتة في `core/constants/strings.dart`.
4. `ThemeCubit` يعزل إعدادات الثيم، و`SessionCubit` يعالج lifecycle الأونلاين/أوفلاين و token.

### المرحلة 5 — الجودة والاختبارات
1. Unit tests: كل use case مع repository وهمي (mocktail/mockito).
2. Bloc tests: كل BLoC مع use case وهمي.
3. Widget tests: شاشة واحدة على الأقل لكل feature مع BLoC مزيف.
4. إصلاح أخطاء الأسبقية في `fromJson`, تسمية `List<String>`, ورسائل الأخطاء.
5. (اختياري) `go_router` بدل `MaterialPageRoute` المباشر.

---

## 5. أولويات التنفيذ

| الأولوية | الملفات المتأثرة | السبب |
|---|---|---|
| P0 | `notification_key.json` / `supabase_config.dart` | تسريب أسرار — يُعالج أولاً |
| P1 | كل الـ domain | قاعدة التبعية — أساس كل ما بعده |
| P1 | كل الـ blocs | غياب DI يمنع كل اختبار |
| P2 | كل الشاشات | تسريب Firestore في الـ presentation |
| P2 | `provider.dart` | God object + ازدواجية إدارة الحالة |
| P3 | الأسماء / الأخطاء الإملائية / الرسائل / الاختبارات | جودة عامة |
