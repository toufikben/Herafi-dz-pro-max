import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/admin_stats_service.dart';
import 'core/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init: $e');
    runApp(ErrorBootApp(e));
    return;
  }
  runApp(const AdminApp());
}

/// شاشة خطأ آمنة عند فشل تهيئة Firebase — تمنع الخروج المفاجئ.
class ErrorBootApp extends StatelessWidget {
  final Object error;
  const ErrorBootApp(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 56, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('تعذّر الاتصال بخدمة Firebase',
                      style: GoogleFonts.cairo(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('$error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const _RestartApp()),
                        (_) => false,
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestartApp extends StatelessWidget {
  const _RestartApp();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

const _primary = Color(0xFF0D9488);

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حرفي الجزائر - الأدمن',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.cairoTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const AdminLoginScreen(),
    );
  }
}

// ───────────────── Login (Firebase Email/Password حقيقي) ─────────────────
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

// حالتا شاشة الدخول: إدخال الرقم أو إدخال رمز التحقق
class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  bool _codeSent = false;
  String? _verificationId;
  int _resendCooldown = 0;

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty || phone.length < 8) {
      _showError('أدخل رقم هاتف صحيح (8 أرقام على الأقل)');
      return;
    }
    final fullNumber =
        phone.startsWith('+') ? phone : '+213$phone'.replaceAll(' ', '');
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cred) async {
          await _signInWithCredential(cred);
        },
        verificationFailed: (FirebaseAuthException e) {
          _handleAuthError(e);
        },
        codeSent: (String id, int? resend) {
          setState(() {
            _verificationId = id;
            _codeSent = true;
            _loading = false;
            _resendCooldown = 30;
          });
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      _showError('فشل إرسال الرمز: $e');
    } finally {
      if (mounted && !_codeSent) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty || code.length < 6) {
      _showError('أدخل رمز التحقق المكوّن من 6 أرقام');
      return;
    }
    final vid = _verificationId;
    if (vid == null) {
      _showError('يجب إرسال الرمز أولاً');
      return;
    }
    setState(() => _loading = true);
    final cred = PhoneAuthProvider.credential(
      verificationId: vid,
      smsCode: code,
    );
    await _signInWithCredential(cred);
    if (mounted && _loading) setState(() => _loading = false);
  }

  Future<void> _signInWithCredential(PhoneAuthCredential cred) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(cred);
      final user = userCredential.user;
      if (user == null) {
        _showError('فشل تسجيل الدخول');
        return;
      }
      // تحقق من صلاحيات الأدمن عبر Custom Claim
      final idToken = await user.getIdTokenResult();
      final isAdmin = (idToken.claims?['admin'] ?? false) == true;
      if (!mounted) return;
      if (!isAdmin) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('حسابك قيد التفعيل — لم تُمنح صلاحيات الأدمن بعد'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 6),
          ),
        );
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminShell()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('فشل تسجيل الدخول: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-phone-number':
        message = 'رقم الهاتف غير صالح';
        break;
      case 'quota-exceeded':
        message = 'تم تجاوز حد إرسال الرسائل — انتظر وأعد المحاولة';
        break;
      case 'network-request-failed':
        message = 'لا يوجد اتصال بالإنترنت';
        break;
      case 'app-not-authorized':
        message = 'التطبيق غير مصرح له (تحقق من SHA-1)';
        break;
      default:
        message = e.message ?? 'فشل إرسال الرمز';
    }
    if (mounted) setState(() => _loading = false);
    _showError(message);
  }

  void _showError(String text) {
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: Colors.red),
    );
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      if (!mounted) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (_resendCooldown > 1) {
        setState(() => _resendCooldown--);
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  'لوحة التحكم',
                  style: GoogleFonts.cairo(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'حرفي الجزائر',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 36),
                if (!_codeSent) ...[
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '541558675',
                      prefixIcon: const Icon(Icons.phone_android_outlined),
                      suffixText: '+213',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('إرسال رمز التحقق',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ] else ...[
                  Text(
                    'أدخل الرمز المرسل إلى +213 ${_phoneCtrl.text.trim()}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'رمز التحقق',
                      hintText: '000000',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('تأكيد',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed:
                        _resendCooldown > 0 ? null : _sendOtp,
                    child: Text(_resendCooldown > 0
                        ? 'إعادة الإرسال بعد $_resendCooldown ث'
                        : 'إعادة إرسال الرمز'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _codeSent = false;
                      _verificationId = null;
                      _codeCtrl.clear();
                    }),
                    child: const Text('تغيير رقم الهاتف'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────── Shell ─────────────────
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _pages = const [
    _StatsPage(),
    _UsersPage(),
    _OrdersPage(),
    _CategoriesPage(),
    _SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'إحصائيات',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'مستخدمون',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'طلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'تخصصات',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'إعدادات',
          ),
        ],
      ),
    );
  }
}

// ───────────────── Helpers ─────────────────
Map<String, String> get _statusAr => {
      'pending': 'معلق',
      'accepted': 'مقبول',
      'rejected': 'مرفوض',
      'inProgress': 'جاري',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
    };

String _statusLabel(String status) => _statusAr[status] ?? status;

Color _statusColor(String status) => switch (status) {
      'pending' => Colors.orange,
      'accepted' => Colors.blue,
      'rejected' => Colors.grey,
      'inProgress' => Colors.blue,
      'completed' => Colors.green,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };

String _roleLabel(String role) => switch (role) {
      'customer' => 'زبون',
      'craftsman' => 'حرفي شخصي',
      'company' => 'مؤسسة',
      'group' => 'مجموعة',
      _ => role,
    };

// ───────────────── Stats (حقيقي من Firestore) ─────────────────
class _StatsPage extends StatefulWidget {
  const _StatsPage();

  @override
  State<_StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<_StatsPage> {
  final AdminStatsService _service = AdminStatsService();
  AdminStats? _stats;
  Object? _error;
  bool _loading = true;

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await _service.fetchStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '${e.code}: ${e.message ?? ""}'.trim();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الإحصائيات')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('تعذّر جلب الإحصائيات الحقيقية'),
                const SizedBox(height: 8),
                Text(
                  '$_error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
              ],
            ),
          ),
        ),
      );
    }
    final stats = _stats!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('نظرة عامة اليوم',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _StatCard(
                  title: 'الزبائن',
                  value: '${stats.customersCount}',
                  icon: Icons.person_rounded,
                  color: const Color(0xFF3B82F6)),
              _StatCard(
                  title: 'الحرفيون',
                  value: '${stats.craftsmenCount}',
                  icon: Icons.handyman_rounded,
                  color: _primary),
              _StatCard(
                  title: 'طلبات اليوم',
                  value: '${stats.todayOrdersCount}',
                  icon: Icons.receipt_rounded,
                  color: const Color(0xFFF59E0B)),
              _StatCard(
                  title: 'متوسط التقييم',
                  value: '${stats.averageRating}',
                  icon: Icons.star_rounded,
                  color: const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat('طلبات جارية/معلقة', '${stats.pendingOrders}',
                  Colors.orange),
              const SizedBox(width: 8),
              _MiniStat('طلبات مكتملة', '${stats.completedOrders}',
                  Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          Text('أكثر التخصصات طلباً',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (stats.topCategories.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('لا توجد طلبات بعد')),
          ...stats.topCategories.entries
              .map((e) => _TopItem(
                    name: e.key,
                    count: e.value,
                    total: stats.completedOrders +
                        stats.pendingOrders,
                  )),
          const SizedBox(height: 24),
          Text('الولايات الأكثر نشاطاً',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (stats.topWilayas.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('لا يوجد مستخدمون بعد')),
          ...stats.topWilayas.entries.map((e) => _TopItem(
                name: e.key,
                count: e.value,
                total: stats.customersCount + stats.craftsmenCount,
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title, value;
  final Color color;

  const _MiniStat(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Text('$title: ', style: TextStyle(color: Colors.grey.shade600)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopItem extends StatelessWidget {
  final String name;
  final int count, total;

  const _TopItem({required this.name, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: total > 0 ? count / total : 0,
                backgroundColor: Colors.grey.shade200,
                color: _primary,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$count',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }
}

// ───────────────── Users (حقيقي من Firestore) ─────────────────
class _UsersPage extends StatefulWidget {
  const _UsersPage();

  @override
  State<_UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<_UsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدمون'),
        bottom: TabBar(
          controller: _tab,
          labelColor: _primary,
          indicatorColor: _primary,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'حرفيون'),
            Tab(text: 'زبائن'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _UserList(filter: 'all'),
          _UserList(filter: 'craftsman'),
          _UserList(filter: 'customer'),
        ],
      ),
    );
  }
}

class _UserList extends StatefulWidget {
  final String filter;
  const _UserList({required this.filter});

  @override
  State<_UserList> createState() => _UserListState();
}

class _UserListState extends State<_UserList> {
  final AdminStatsService _service = AdminStatsService();
  List<Map<String, dynamic>>? _users;
  Object? _error;
  bool _loading = true;

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await _service.fetchAllUsers(roleFilter: widget.filter);
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _handleAction(String uid, String action,
      Map<String, dynamic> data) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      switch (action) {
        case 'verify':
          final verified = data['isVerified'] == true;
          await _service.setVerified(uid, !verified);
          messenger.showSnackBar(SnackBar(
              content: Text(!verified ? 'تم توثيق المستخدم' : 'تم إلغاء التوثيق')));
          break;
        case 'block':
          final blocked = data['isBlocked'] == true;
          await _service.setBlocked(uid, !blocked);
          messenger.showSnackBar(SnackBar(
              content: Text(!blocked ? 'تم حظر المستخدم' : 'تم إلغاء الحظر')));
          break;
        case 'view':
          _showUserDetails(uid, data);
          break;
        default:
          messenger.showSnackBar(SnackBar(content: Text('إجراء غير معروف: $action')));
      }
      await _load();
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('فشل الإجراء: $e'), backgroundColor: Colors.red));
    }
  }

  void _showUserDetails(String uid, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_fullName(data),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('الهاتف: ${data['phone'] ?? '-'}'),
            Text('النوع: ${_roleLabel(data['role'] ?? '')}'),
            Text('الولاية: ${data['wilaya'] ?? '-'} • البلدية: ${data['commune'] ?? '-'}'),
            Text('العنوان: ${data['address'] ?? '-'}'),
            if (data['specialties'] != null)
              Text('التخصصات: ${(data['specialties'] as List).join('، ')}'),
            Text('خبرة: ${data['yearsOfExperience'] ?? '-'} سنة'),
            Text('التقييم: ${data['rating'] ?? 0} (${data['ratingCount'] ?? 0} تقييم)'),
            Text('موثّق: ${data['isVerified'] == true ? 'نعم' : 'لا'}'),
            Text('محظور: ${data['isBlocked'] == true ? 'نعم' : 'لا'}'),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  String _fullName(Map<String, dynamic> data) =>
      (data['fullName'] as String?)?.isNotEmpty == true
          ? data['fullName'] as String
          : 'مستخدم بدون اسم';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('تعذّر جلب المستخدمين الحقيقيين'),
              const SizedBox(height: 8),
              Text(
                '$_error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }
    if (_users == null || _users!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 48),
              const SizedBox(height: 16),
              Text(widget.filter == 'craftsman'
                  ? 'لا يوجد حرفيون مسجلون بعد'
                  : widget.filter == 'customer'
                      ? 'لا يوجد زبائن مسجلون بعد'
                      : 'لا يوجد مستخدمون مسجلون بعد'),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _users!.length,
      itemBuilder: (context, i) {
        final data = _users![i];
        final role = data['role'] as String? ?? 'customer';
        final isCraftsman = role != 'customer';
        final wilaya = data['wilaya'] ?? '';
        final specialties = (data['specialties'] as List?)?.join('، ') ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCraftsman
                  ? _primary.withOpacity(0.15)
                  : Colors.blue.withOpacity(0.15),
              child: Icon(
                isCraftsman ? Icons.handyman_rounded : Icons.person_rounded,
                color: isCraftsman ? _primary : Colors.blue,
                size: 22,
              ),
            ),
            title: Text(
              _fullName(data),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${_roleLabel(role)}${isCraftsman && specialties.isNotEmpty ? ' • $specialties' : ''}${wilaya.isNotEmpty ? ' • $wilaya' : ''}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (v) => _handleAction(data['uid'], v, data),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'view', child: Text('عرض التفاصيل')),
                const PopupMenuItem(value: 'verify', child: Text('توثيق')),
                const PopupMenuItem(value: 'block', child: Text('حظر')),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ───────────────── Orders (حقيقي من Firestore) ─────────────────
class _OrdersPage extends StatefulWidget {
  const _OrdersPage();

  @override
  State<_OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<_OrdersPage> {
  final AdminStatsService _service = AdminStatsService();
  List<Map<String, dynamic>>? _orders;
  Map<String, Map<String, dynamic>>? _usersByName;
  Object? _error;
  bool _loading = true;

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await _service.fetchAllOrders();
      final uids = <String>{};
      for (final o in orders) {
        if (o['customerId'] != null) uids.add(o['customerId']);
        if (o['craftsmanId'] != null) uids.add(o['craftsmanId']);
      }
      final usersByName = await _service.fetchUsersByIds(uids.toList());
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _usersByName = usersByName;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _name(String? uid) {
    if (uid == null) return '-';
    final u = _usersByName?[uid];
    if (u == null) return 'مستخدم ($uid)';
    final fn = u['fullName'] as String?;
    return (fn != null && fn.isNotEmpty) ? fn : 'مستخدم ($uid)';
  }

  String _dateLabel(String? createdAt) {
    if (createdAt == null) return '';
    final d = DateTime.tryParse(createdAt);
    if (d == null) return createdAt;
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الطلبات')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('تعذّر جلب الطلبات الحقيقية'),
                const SizedBox(height: 8),
                Text(
                  '$_error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
              ],
            ),
          ),
        ),
      );
    }
    if (_orders == null || _orders!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('الطلبات')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 48),
                SizedBox(height: 16),
                Text('لا توجد طلبات حقيقية بعد'),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _orders!.length,
          itemBuilder: (context, i) {
            final order = _orders![i];
            final status = order['status'] as String? ?? 'pending';
            final specialty = order['categoryId'] ?? '-';
            final wilaya = order['wilaya'] ?? '';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  'طلب • ${_dateLabel(order['createdAt'])}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '$specialty${wilaya.isNotEmpty ? ' • $wilaya' : ''} • ${_statusLabel(status)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Chip(
                  label: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontSize: 11,
                      color: _statusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: _statusColor(status).withOpacity(0.12),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تفاصيل الطلب',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          Text('الزبون: ${_name(order['customerId'])}'),
                          Text('الحرفي: ${_name(order['craftsmanId'])}'),
                          Text('التخصص: ${order['categoryId'] ?? '-'}'),
                          Text('الموقع: ${order['wilaya'] ?? ''}${order['commune']?.isNotEmpty == true ? ' • ${order['commune']}' : ''}${order['address']?.isNotEmpty == true ? ' • ${order['address']}' : ''}'),
                          Text('الوصف: ${order['description'] ?? '-'}'),
                          Text('التاريخ: ${_dateLabel(order['createdAt'])}'),
                          Text('الحالة: ${_statusLabel(status)}'),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('إغلاق'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ───────────────── Categories (قائمة التخصصات المعتمدة في التطبيق) ─────────────────
class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage();

  static const _cats = [
    ('كهربائي', Icons.bolt_rounded),
    ('سباك', Icons.water_drop_rounded),
    ('نجار', Icons.carpenter_rounded),
    ('دهان', Icons.format_paint_rounded),
    ('تكييف وتبريد', Icons.ac_unit_rounded),
    ('تنظيف', Icons.cleaning_services_rounded),
    ('بناء وترميم', Icons.construction_rounded),
    ('ميكانيكي', Icons.car_repair_rounded),
    ('إصلاح أجهزة', Icons.home_repair_service_rounded),
    ('لحام', Icons.build_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التخصصات')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _cats.length,
        itemBuilder: (context, i) {
          final (name, icon) = _cats[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _primary.withOpacity(0.12),
                child: Icon(icon, color: _primary, size: 22),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('تخصص معتمد في التطبيق'),
            ),
          );
        },
      ),
    );
  }
}

// ───────────────── Settings ─────────────────
class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_city_outlined),
            title: const Text('الولايات والبلديات'),
            subtitle: const Text('58 ولاية مع بلدياتها — داخل التطبيق الرئيسي'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('إعدادات الإشعارات'),
            subtitle: const Text('تُرسل من Cloud Functions على Firebase'),
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('الصلاحيات والأدوار'),
            subtitle: const Text('صلاحية admin عبر Custom Claims في Firebase Auth'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('عن التطبيق'),
            subtitle: const Text('الإصدار 1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('تسجيل الخروج',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                (r) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
