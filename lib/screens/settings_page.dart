import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF111A22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CPR Holoprint', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              SizedBox(height: 5),
              Text('الإصدار 0.1.0 · Android', style: TextStyle(color: Colors.white54, fontSize: 11)),
              SizedBox(height: 14),
              Text(
                'أداة من CPR لتنظيم عملية تحويل هياكل Minecraft Bedrock إلى حزم Holoprint.',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle('المصادر والتراخيص'),
        _SettingsTile(
          icon: Icons.open_in_new_rounded,
          title: 'مشروع HoloPrint الأصلي',
          subtitle: 'مستودع المصدر والتطوير',
          onTap: () => _open('https://github.com/SuperLlama88888/holoprint'),
        ),
        _SettingsTile(
          icon: Icons.article_outlined,
          title: 'شروط استخدام HoloPrint',
          subtitle: 'راجع ترخيص الحزم الناتجة قبل توزيعها',
          onTap: () => _open('https://github.com/SuperLlama88888/holoprint/blob/main/TERMS_OF_USE.md'),
        ),
        _SettingsTile(
          icon: Icons.menu_book_outlined,
          title: 'دليل HoloPrint',
          subtitle: 'طريقة استخدام الهولوبرنت والتحكم به',
          onTap: () => _open('https://holoprint-mc.github.io/wiki/'),
        ),
        const SizedBox(height: 18),
        const _SectionTitle('معلومات مهمة'),
        const _InfoTile(
          icon: Icons.cloud_outlined,
          title: 'المعالجة عبر الإنترنت',
          text: 'نسخة CPR الحالية تعرض محرك HoloPrint الرسمي داخل التطبيق. لذلك يلزم اتصال بالإنترنت، وقد تتغير واجهة المحرك أو توفره وفق الموقع الأصلي.',
        ),
        const _InfoTile(
          icon: Icons.folder_copy_outlined,
          title: 'صلاحيات الملفات',
          text: 'التطبيق يستخدم نافذة اختيار وحفظ الملفات في أندرويد. لا يحتاج إلى الوصول إلى Android/data ولا يطلب صلاحية الوصول الشامل للملفات.',
        ),
        const _InfoTile(
          icon: Icons.copyright_outlined,
          title: 'ترخيص الحزم الناتجة',
          text: 'شروط HoloPrint تنص على أن الحزم المنشأة به مرخصة وفق CC BY-NC-SA 4.0، وتتضمن قيوداً على البيع أو وضع الحزم خلف إعلانات أو روابط مدفوعة.',
        ),
        const SizedBox(height: 18),
        Center(
          child: Text('CPR · Built for Bedrock creators', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 10, letterSpacing: 0.5)),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF75DCCB), fontSize: 12)),
      );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: const Color(0xFF111A22),
          borderRadius: BorderRadius.circular(15),
          child: ListTile(
            onTap: onTap,
            leading: Icon(icon, color: const Color(0xFF71DCC8)),
            title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white54)),
            trailing: const Icon(Icons.chevron_left_rounded, color: Colors.white38),
          ),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF111A22), borderRadius: BorderRadius.circular(15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF71DCC8), size: 20),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(text, style: const TextStyle(color: Colors.white60, fontSize: 10, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
