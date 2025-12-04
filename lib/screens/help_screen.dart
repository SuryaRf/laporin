import 'package:flutter/material.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Apa itu Laporin?',
      answer:
          'Laporin adalah aplikasi pelaporan keluhan untuk kampus yang memudahkan mahasiswa dan dosen melaporkan berbagai permasalahan atau keluhan di lingkungan kampus secara cepat dan terorganisir.',
      icon: Icons.info_outline,
      category: 'Umum',
    ),
    FAQItem(
      question: 'Bagaimana cara membuat laporan?',
      answer:
          '1. Klik tombol "Buat Laporan" di halaman utama\n'
          '2. Pilih kategori laporan (Fasilitas, Akademik, Keamanan, dll)\n'
          '3. Isi judul dan deskripsi laporan dengan jelas\n'
          '4. Tambahkan foto jika diperlukan\n'
          '5. Tentukan tingkat prioritas\n'
          '6. Klik "Kirim Laporan"',
      icon: Icons.create_outlined,
      category: 'Laporan',
    ),
    FAQItem(
      question: 'Berapa lama laporan akan diproses?',
      answer:
          'Waktu pemrosesan laporan bervariasi tergantung kompleksitas masalah:\n'
          '• Prioritas Tinggi: 1-2 hari kerja\n'
          '• Prioritas Sedang: 3-5 hari kerja\n'
          '• Prioritas Rendah: 7-14 hari kerja\n\n'
          'Tim admin akan segera meninjau dan memproses laporan Anda.',
      icon: Icons.schedule_outlined,
      category: 'Laporan',
    ),
    FAQItem(
      question: 'Bagaimana cara melacak status laporan saya?',
      answer:
          'Anda dapat melacak status laporan dengan cara:\n'
          '1. Buka menu "Riwayat Laporan" dari drawer\n'
          '2. Lihat semua laporan yang pernah Anda buat\n'
          '3. Status akan ditampilkan dengan badge berwarna:\n'
          '   • Biru: Sedang Diproses\n'
          '   • Hijau: Disetujui\n'
          '   • Merah: Ditolak\n'
          '4. Klik laporan untuk melihat detail dan catatan admin',
      icon: Icons.track_changes_outlined,
      category: 'Laporan',
    ),
    FAQItem(
      question: 'Apa yang dimaksud dengan notifikasi?',
      answer:
          'Notifikasi adalah pemberitahuan yang dikirim kepada Anda ketika:\n'
          '• Laporan Anda disetujui oleh admin\n'
          '• Laporan Anda ditolak dengan alasan\n'
          '• Status laporan Anda berubah\n\n'
          'Anda akan menerima notifikasi real-time di aplikasi dan dapat mengaksesnya melalui menu Notifikasi.',
      icon: Icons.notifications_outlined,
      category: 'Notifikasi',
    ),
    FAQItem(
      question: 'Kategori laporan apa saja yang tersedia?',
      answer:
          'Laporin menyediakan berbagai kategori:\n'
          '• 🏢 Fasilitas - Kerusakan atau masalah infrastruktur\n'
          '• 📚 Akademik - Masalah pembelajaran dan perkuliahan\n'
          '• 🔒 Keamanan - Isu keamanan dan ketertiban\n'
          '• 🍽️ Kantin - Keluhan seputar kantin dan makanan\n'
          '• 🚗 Parkir - Masalah area parkir\n'
          '• 🧹 Kebersihan - Masalah sanitasi dan kebersihan\n'
          '• 📡 IT/Teknologi - Masalah teknis dan jaringan\n'
          '• 🎭 Lainnya - Kategori lain yang relevan',
      icon: Icons.category_outlined,
      category: 'Laporan',
    ),
    FAQItem(
      question: 'Apakah saya bisa mengedit laporan yang sudah dibuat?',
      answer:
          'Anda dapat mengedit laporan HANYA jika statusnya masih "Sedang Diproses". Setelah laporan disetujui atau ditolak, Anda tidak dapat mengeditnya lagi. Jika ada informasi tambahan, Anda bisa membuat laporan baru.',
      icon: Icons.edit_outlined,
      category: 'Laporan',
    ),
    FAQItem(
      question: 'Bagaimana jika laporan saya ditolak?',
      answer:
          'Jika laporan Anda ditolak:\n'
          '1. Anda akan menerima notifikasi\n'
          '2. Buka detail laporan untuk melihat alasan penolakan dari admin\n'
          '3. Perbaiki informasi sesuai catatan admin\n'
          '4. Buat laporan baru dengan informasi yang lebih lengkap\n\n'
          'Penolakan biasanya terjadi karena informasi kurang lengkap atau laporan duplikat.',
      icon: Icons.cancel_outlined,
      category: 'Laporan',
    ),
    FAQItem(
      question: 'Apakah identitas pelapor dirahasiakan?',
      answer:
          'Identitas pelapor akan ditampilkan di sistem untuk keperluan verifikasi dan tindak lanjut. Namun, data pribadi Anda dilindungi dan hanya dapat diakses oleh admin yang berwenang.',
      icon: Icons.privacy_tip_outlined,
      category: 'Privasi',
    ),
    FAQItem(
      question: 'Bagaimana cara menghubungi admin?',
      answer:
          'Saat ini komunikasi dengan admin dilakukan melalui:\n'
          '1. Catatan admin pada laporan yang ditolak atau disetujui\n'
          '2. Sistem notifikasi dalam aplikasi\n\n'
          'Untuk pertanyaan lebih lanjut, hubungi bagian IT kampus atau help desk.',
      icon: Icons.contact_support_outlined,
      category: 'Umum',
    ),
    FAQItem(
      question: 'Apa yang harus dilakukan jika mengalami kendala teknis?',
      answer:
          'Jika mengalami kendala teknis:\n'
          '1. Pastikan koneksi internet Anda stabil\n'
          '2. Coba logout dan login kembali\n'
          '3. Periksa apakah aplikasi sudah versi terbaru\n'
          '4. Clear cache aplikasi jika perlu\n'
          '5. Jika masalah berlanjut, hubungi tim IT kampus dengan detail error yang dialami',
      icon: Icons.build_outlined,
      category: 'Teknis',
    ),
  ];

  String? _selectedCategory;
  List<String> get _categories {
    final cats = _faqItems.map((e) => e.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<FAQItem> get _filteredItems {
    if (_selectedCategory == null) return _faqItems;
    return _faqItems.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan & FAQ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Pusat Bantuan',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Temukan jawaban untuk pertanyaan Anda',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Category filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('Semua', null),
                  const SizedBox(width: 8),
                  ..._categories.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildCategoryChip(category, category),
                      )),
                ],
              ),
            ),
          ),

          // FAQ List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return _buildFAQCard(item);
              },
            ),
          ),
        ],
      ),

      // Contact support button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tidak menemukan jawaban yang Anda cari?',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _showContactDialog(context);
                },
                icon: const Icon(Icons.contact_support_outlined),
                label: const Text('Hubungi Admin'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.greyLight,
      ),
    );
  }

  Widget _buildFAQCard(FAQItem item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.greyLight),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          title: Text(
            item.question,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              item.category,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.answer,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.contact_support, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Hubungi Kami'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jika Anda memiliki pertanyaan lebih lanjut atau mengalami kendala, silakan hubungi:',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.email_outlined,
              'Email',
              'support@laporin.ac.id',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.phone_outlined,
              'Telepon',
              '(021) 1234-5678',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.schedule_outlined,
              'Jam Operasional',
              'Senin - Jumat, 08:00 - 17:00',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final IconData icon;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.icon,
    required this.category,
  });
}
