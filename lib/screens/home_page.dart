import 'package:material_ui/material_ui.dart';

import '../models/export_entry.dart';
import '../services/history_store.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.onOpenConverter,
    required this.historyRevision,
    super.key,
  });

  final VoidCallback onOpenConverter;
  final int historyRevision;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<ExportEntry>>(
      key: ValueKey(historyRevision),
      future: HistoryStore.load(),
      builder: (context, snapshot) {
        final exports = snapshot.data ?? const <ExportEntry>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF173D42), Color(0xFF12232D)],
                ),
                border: Border.all(color: const Color(0xFF4FD9C3).withValues(alpha: 0.22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF57DCC5).withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'CPR BUILD TOOLS',
                          style: TextStyle(
                            color: Color(0xFF77E8D4),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.view_in_ar_rounded, color: Color(0xFF7AE6D5), size: 28),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'حوّل بناياتك إلى\nهولوبرنت جاهز للبناء',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.28,
                      color: const Color(0xFFF2FAF9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'استورد ملفات Minecraft Bedrock، اضبط إعدادات العرض، وأنشئ حزمة موارد لهولوبرنت.',
                    style: TextStyle(color: Color(0xFFB7CBCB), height: 1.55, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onOpenConverter,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('ابدأ إنشاء هولوبرنت'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5BE0C8),
                        foregroundColor: const Color(0xFF071A18),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'الحزم المحفوظة',
                    value: '${exports.length}',
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _StatCard(
                    icon: Icons.wifi_rounded,
                    label: 'محرك التحويل',
                    value: 'ويب',
                    valueColor: Color(0xFF6FE0C9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 27),
            Text('شنو تقدر تسوي؟', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const _FeatureRow(
              icon: Icons.view_in_ar_outlined,
              title: 'تحويل MCStructure',
              description: 'ارفع ملفاً واحداً أو عدة ملفات لبناء حزمة هولوبرنت.',
            ),
            const _FeatureRow(
              icon: Icons.public_rounded,
              title: 'استخراج من عالم',
              description: 'استيراد ملفات MCWorld أو MCTemplate أو ZIP المتوافقة.',
            ),
            const _FeatureRow(
              icon: Icons.system_update_alt_rounded,
              title: 'تحديث حزمة قديمة',
              description: 'استيراد حزم Structura أو HoloPrint القديمة عند دعمها.',
            ),
            const _FeatureRow(
              icon: Icons.tune_rounded,
              title: 'إعدادات الهولوبرنت',
              description: 'تخصيص الشفافية والطبقات والتحكم والبيانات الوصفية.',
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF17232D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF79CFC4), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'محرك HoloPrint الأصلي يُفتح داخل التطبيق عبر الإنترنت. الاتصال مطلوب لإجراء التحويل وتنزيل الحزمة.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF111A22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF64D8C3), size: 20),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: valueColor)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF173B3C),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF74E2D0), size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(description, style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.45)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
