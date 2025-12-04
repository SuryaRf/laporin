import 'package:flutter/material.dart';
import 'package:laporin/constants/colors.dart';

// User Role Enum
enum UserRole {
  user, // Default role untuk user biasa
  mahasiswa,
  dosen,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.mahasiswa:
        return 'Mahasiswa';
      case UserRole.dosen:
        return 'Staff/Pengelola';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  String get description {
    switch (this) {
      case UserRole.user:
        return 'Masyarakat umum - dapat membuat dan melihat laporan sendiri';
      case UserRole.mahasiswa:
        return 'Civitas akademik (mahasiswa) - dapat membuat dan melihat laporan';
      case UserRole.dosen:
        return 'Staff atau pengelola - dapat mengelola laporan';
      case UserRole.admin:
        return 'Administrator - akses penuh untuk mengelola sistem';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.user:
        return AppColors.textSecondary;
      case UserRole.mahasiswa:
        return AppColors.primary;
      case UserRole.dosen:
        return AppColors.secondary;
      case UserRole.admin:
        return AppColors.error;
    }
  }
}

// Report Category Enum
enum ReportCategory {
  kerusakan,
  keamanan,
  kebersihan,
  fasilitas,
  lainnya;

  String get displayName {
    switch (this) {
      case ReportCategory.kerusakan:
        return 'Kerusakan';
      case ReportCategory.keamanan:
        return 'Keamanan';
      case ReportCategory.kebersihan:
        return 'Kebersihan';
      case ReportCategory.fasilitas:
        return 'Fasilitas';
      case ReportCategory.lainnya:
        return 'Lainnya';
    }
  }

  String get emoji {
    switch (this) {
      case ReportCategory.kerusakan:
        return '🔧';
      case ReportCategory.keamanan:
        return '🔒';
      case ReportCategory.kebersihan:
        return '🧹';
      case ReportCategory.fasilitas:
        return '🏢';
      case ReportCategory.lainnya:
        return '📋';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportCategory.kerusakan:
        return Icons.build_outlined;
      case ReportCategory.keamanan:
        return Icons.security_outlined;
      case ReportCategory.kebersihan:
        return Icons.cleaning_services_outlined;
      case ReportCategory.fasilitas:
        return Icons.business_outlined;
      case ReportCategory.lainnya:
        return Icons.more_horiz_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ReportCategory.kerusakan:
        return AppColors.warning;
      case ReportCategory.keamanan:
        return AppColors.error;
      case ReportCategory.kebersihan:
        return Colors.green;
      case ReportCategory.fasilitas:
        return AppColors.primary;
      case ReportCategory.lainnya:
        return AppColors.textSecondary;
    }
  }
}

// Report Status Enum
enum ReportStatus {
  inProgress, // Status awal saat laporan dibuat (Diajukan)
  approved, // Laporan disetujui oleh admin
  rejected; // Laporan ditolak oleh admin

  String get displayName {
    switch (this) {
      case ReportStatus.inProgress:
        return 'Diajukan';
      case ReportStatus.approved:
        return 'Disetujui';
      case ReportStatus.rejected:
        return 'Ditolak';
    }
  }

  String get description {
    switch (this) {
      case ReportStatus.inProgress:
        return 'Laporan sedang menunggu persetujuan';
      case ReportStatus.approved:
        return 'Laporan telah disetujui';
      case ReportStatus.rejected:
        return 'Laporan ditolak';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.inProgress:
        return AppColors.warning; // Orange/kuning untuk menunggu
      case ReportStatus.approved:
        return AppColors.success;
      case ReportStatus.rejected:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case ReportStatus.inProgress:
        return Icons.pending_outlined;
      case ReportStatus.approved:
        return Icons.check_circle_outline;
      case ReportStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  // Check if report can be edited/deleted by user
  bool get canBeModified {
    return this == ReportStatus.inProgress;
  }
}

// Priority Enum
enum ReportPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case ReportPriority.low:
        return 'Rendah';
      case ReportPriority.medium:
        return 'Sedang';
      case ReportPriority.high:
        return 'Tinggi';
      case ReportPriority.urgent:
        return 'Mendesak';
    }
  }

  String get description {
    switch (this) {
      case ReportPriority.low:
        return 'Tidak mengganggu aktivitas, bisa ditangani nanti';
      case ReportPriority.medium:
        return 'Cukup mengganggu, perlu segera ditangani';
      case ReportPriority.high:
        return 'Sangat mengganggu aktivitas, butuh penanganan cepat';
      case ReportPriority.urgent:
        return 'Berbahaya/kritis, memerlukan tindakan segera!';
    }
  }

  String get example {
    switch (this) {
      case ReportPriority.low:
        return 'Contoh: Cat dinding mengelupas, lampu mati 1 buah';
      case ReportPriority.medium:
        return 'Contoh: Kursi rusak, AC kurang dingin';
      case ReportPriority.high:
        return 'Contoh: Proyektor tidak nyala, pintu rusak';
      case ReportPriority.urgent:
        return 'Contoh: Kebocoran parah, kabel terkelupas, bahaya keamanan';
    }
  }

  Color get color {
    switch (this) {
      case ReportPriority.low:
        return AppColors.success;
      case ReportPriority.medium:
        return Colors.blue;
      case ReportPriority.high:
        return AppColors.warning;
      case ReportPriority.urgent:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case ReportPriority.low:
        return Icons.flag_outlined;
      case ReportPriority.medium:
        return Icons.flag_outlined;
      case ReportPriority.high:
        return Icons.flag;
      case ReportPriority.urgent:
        return Icons.flag;
    }
  }
}
