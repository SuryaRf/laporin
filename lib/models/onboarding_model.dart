class OnboardingModel {
  final String title;
  final String description;
  final String image;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.image,
  });
}

List<OnboardingModel> onboardingData = [
  OnboardingModel(
    title: 'Laporkan Kerusakan',
    description: 'Laporkan kerusakan fasilitas kampus dengan mudah dan cepat melalui smartphone Anda',
    image: 'assets/images/screen_1.jpeg',
  ),
  OnboardingModel(
    title: 'Pantau Status Laporan',
    description: 'Pantau status laporan Anda secara real-time dan dapatkan notifikasi update terbaru',
    image: 'assets/images/screen_2.jpeg',
  ),
  OnboardingModel(
    title: 'Fasilitas Lebih Baik',
    description: 'Berkontribusi untuk fasilitas kampus yang lebih baik dan nyaman untuk semua',
    image: 'assets/images/screen_3.jpeg',
  ),
];
