# توصيلة أمان - كابتن فلاش ⚡ | Tawsila Aman

> تطبيق توصيل ذكي يربط العميل بأقرب دليفري فاضي في ثواني - بدون جوجل مابس مدفوع.

### 🎯 الفكرة
العميل يفتح الخريطة، يشوف الدليفري الفاضي 🟢، يدوس طلب، الدليفري يقبل ويتحول 🔴 مشغول، يخلص الرحلة ويرجع 🟢 تاني.

### 💰 نظام الحساب
سعر الرحلة = 13 جنيه (فتحة عداد) + 5 جنيه × عدد الكيلومترات
عمولة التطبيق = 10% للكابتن الممتاز / 15% للعادي
ربح الدليفري = سعر الرحلة - العمولة

مثال: رحلة 4 كيلو = 13 + 20 = 33 جنيه
- لو ممتاز: عمولتك 3.3ج، الدليفري ياخد 29.7ج
- لو عادي: عمولتك 4.95ج، الدليفري ياخد 28.05ج

### ✨ المميزات
- 🗺️ خريطة OSM مجانية 100%
- 💬 شات مباشر بين العميل والدليفري
- 📍 تتبع لحظي لحالة الدليفري (فاضي/مشغول)
- 📊 لوحة تحكم للمالك: كل الشيكات، الأرباح، عدد الرحلات
- ⚡ حساب تلقائي للسعر والمسافة والعمولة
- 🔔 إشعارات فورية

### 📁 هيكل المشروع (12 ملف أساسي)
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user_model.dart
│   └── order_model.dart
├── services/
│   ├── location_service.dart
│   ├── order_service.dart
│   └── notification_service.dart
└── screens/
    ├── login_screen.dart
    ├── map_screen_osm.dart
    ├── chat_screen.dart
    ├── delivery/
    │   └── delivery_home.dart
    └── owner/
        └── owner_dashboard.dart

android/ - ملفات بناء الأندرويد (مهمة لجوجل بلاي)
ios/ - ملفات بناء الآيفون
web/ - نسخة الويب

### 🚀 التشغيل
git clone https://github.com/mabr/tawsila-aman.git
cd tawsila-aman
flutter pub get
flutterfire configure
flutter run
flutter build appbundle

### 🛠️ التكنولوجيا
- Flutter 3
- Firebase (Auth + Firestore)
- flutter_map + OSM
- Geolocator

### 👨‍💻 المالك
Abdo Mabrouk - Toukh, Qalyubia
