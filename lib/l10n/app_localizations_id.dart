// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Streakly';

  @override
  String get todayTab => 'Hari Ini';

  @override
  String get allTab => 'Semua';

  @override
  String get todayHeader => 'Hari Ini';

  @override
  String get allHeader => 'Semua';

  @override
  String get motivationalAllComplete =>
      '🎉 Luar biasa! Anda telah menyelesaikan semua kebiasaan hari ini!';

  @override
  String motivationalProgress(int completed, int total) {
    return '$completed dari $total selesai. Terus lanjutkan!';
  }

  @override
  String get motivationalStart =>
      'Siap membuat hari ini berarti? Mulai dengan satu kebiasaan.';

  @override
  String get noHabitsToday => 'Tidak ada kebiasaan untuk hari ini';

  @override
  String get noHabitsYet => 'Belum ada kebiasaan';

  @override
  String get noHabitsTodayMessage =>
      'Istirahat sejenak dan kembali lagi besok!';

  @override
  String get noHabitsYetMessage =>
      'Perjalanan Anda menuju kebiasaan yang lebih baik dimulai di sini.';

  @override
  String get createFirstHabit => 'Buat Kebiasaan Pertama Anda';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Hapus';

  @override
  String get cancel => 'Batal';

  @override
  String get undo => 'URUNGKAN';

  @override
  String get deleteHabitTitle => 'Hapus Kebiasaan?';

  @override
  String deleteHabitMessage(String habitTitle) {
    return 'Apakah Anda yakin ingin menghapus \"$habitTitle\"?';
  }

  @override
  String deletingHabit(String habitTitle) {
    return 'Menghapus $habitTitle...';
  }

  @override
  String deletedHabit(String habitTitle) {
    return 'Menghapus $habitTitle';
  }

  @override
  String get habitCompleted => 'Kebiasaan ditandai selesai';

  @override
  String get habitIncomplete => 'Kebiasaan ditandai belum selesai';

  @override
  String errorUpdatingHabit(String error) {
    return 'Kesalahan memperbarui kebiasaan: $error';
  }

  @override
  String failedToDelete(String error) {
    return 'Gagal menghapus: $error';
  }

  @override
  String get somethingWentWrong => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get createHabit => 'Buat Kebiasaan';

  @override
  String get editHabit => 'Edit Kebiasaan';

  @override
  String get updateHabit => 'Perbarui Kebiasaan';

  @override
  String get habitName => 'Nama Kebiasaan';

  @override
  String get habitNameHint => 'contoh: Olahraga Pagi, Membaca selama 30 menit';

  @override
  String get descriptionOptional => 'Deskripsi (Opsional)';

  @override
  String get descriptionHint => 'Tambahkan detail tentang kebiasaan Anda...';

  @override
  String get reminderTime => 'Waktu Pengingat';

  @override
  String get repeatDays => 'Ulangi Hari';

  @override
  String get everyday => 'Setiap Hari';

  @override
  String get pleaseEnterHabitName => 'Silakan masukkan nama kebiasaan';

  @override
  String get pleaseSelectAtLeastOneDay => 'Silakan pilih setidaknya satu hari';

  @override
  String get habitCreatedSuccessfully => 'Kebiasaan berhasil dibuat!';

  @override
  String get habitUpdatedSuccessfully => 'Kebiasaan berhasil diperbarui!';

  @override
  String failedToCreateHabit(String error) {
    return 'Gagal membuat kebiasaan: $error';
  }

  @override
  String failedToUpdateHabit(String error) {
    return 'Gagal memperbarui kebiasaan: $error';
  }

  @override
  String get monday => 'Senin';

  @override
  String get tuesday => 'Selasa';

  @override
  String get wednesday => 'Rabu';

  @override
  String get thursday => 'Kamis';

  @override
  String get friday => 'Jumat';

  @override
  String get saturday => 'Sabtu';

  @override
  String get sunday => 'Minggu';

  @override
  String get mon => 'Sen';

  @override
  String get tue => 'Sel';

  @override
  String get wed => 'Rab';

  @override
  String get thu => 'Kam';

  @override
  String get fri => 'Jum';

  @override
  String get sat => 'Sab';

  @override
  String get sun => 'Min';

  @override
  String get habitDetails => 'Detail Kebiasaan';

  @override
  String get loading => 'Memuat...';

  @override
  String get error => 'Kesalahan';

  @override
  String get habitNotFound => 'Kebiasaan tidak ditemukan';

  @override
  String reminderAt(String time) {
    return 'Pengingat pada $time';
  }

  @override
  String get statistics => 'Statistik';

  @override
  String get currentStreak => 'Streak Saat Ini';

  @override
  String get days => 'hari';

  @override
  String get totalCompleted => 'Total Selesai';

  @override
  String get times => 'kali';

  @override
  String get calendar => 'Kalender';

  @override
  String get failedToLoadCalendar => 'Gagal memuat kalender';

  @override
  String get oops => 'Ups!';

  @override
  String get everyDay => 'Setiap hari';

  @override
  String get deleteHabit => 'Hapus Kebiasaan';

  @override
  String get deleteHabitConfirmation =>
      'Apakah Anda yakin ingin menghapus kebiasaan ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get habitDeletedSuccessfully => 'Kebiasaan berhasil dihapus';

  @override
  String failedToDeleteHabit(String error) {
    return 'Gagal menghapus kebiasaan: $error';
  }

  @override
  String dayStreak(int days) {
    return '🔥 $days hari berturut-turut';
  }

  @override
  String get habitNotAvailableToday => 'Kebiasaan ini tidak tersedia';

  @override
  String get tutorialWelcomeTitle => 'Selamat Datang di Streakly! 👋';

  @override
  String get tutorialWelcomeDescription =>
      'Bangun kebiasaan yang lebih baik, satu hari dalam satu waktu. Mari ikuti tur singkat untuk memulai!';

  @override
  String get tutorialCreateTitle => 'Buat Kebiasaan Pertama Anda';

  @override
  String get tutorialCreateDescription =>
      'Ketuk tombol + untuk membuat kebiasaan baru. Atur nama, waktu pengingat, dan pilih hari mana Anda ingin melacaknya.';

  @override
  String get tutorialSwipeLeftTitle => 'Geser ke Kiri untuk Edit ✏️';

  @override
  String get tutorialSwipeLeftDescription =>
      'Geser kartu kebiasaan dari kiri ke kanan untuk mengedit detail, waktu pengingat, atau jadwalnya dengan cepat.';

  @override
  String get tutorialSwipeRightTitle => 'Geser ke Kanan untuk Hapus 🗑️';

  @override
  String get tutorialSwipeRightDescription =>
      'Geser kartu kebiasaan dari kanan ke kiri untuk menghapusnya. Jangan khawatir, kami akan meminta konfirmasi terlebih dahulu!';

  @override
  String get tutorialCompleteTitle => 'Semua Siap! 🎉';

  @override
  String get tutorialCompleteDescription =>
      'Ketuk kartu kebiasaan untuk menandainya selesai dan membangun streak Anda. Siap memulai perjalanan Anda?';

  @override
  String get tutorialNext => 'Selanjutnya';

  @override
  String get tutorialBack => 'Kembali';

  @override
  String get tutorialSkip => 'Lewati';

  @override
  String get tutorialGetStarted => 'Mulai';

  @override
  String get tutorialSwipeCard => 'Kartu Kebiasaan';
}
