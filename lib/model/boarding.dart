class OnboardingInfo {
  final String title;
  final String descriptions;
  final String image;

  OnboardingInfo({
    required this.title,
    required this.descriptions,
    required this.image,
  });
}

class OnboardingItems {
  List<OnboardingInfo> items = [
    OnboardingInfo(
      title: "SEPUH",
      descriptions:
          "Sistem penjadwalan untuk rumah sakit yang dirancang untuk memanajemen informasi pasien, manajemen informasi dan jadwal dokter, serta jadwal periksa.",
      image: "assets/board1.png",
    ),
    OnboardingInfo(
      title: "VISI",
      descriptions:
          "Menjadi sistem penjadwalan terdepan yang membantu rumah sakit dalam memberikan pelayanan kesehatan yang efisien dan berkualitas tinggi untuk semua pasien.",
      image: "assets/board2.png",
    ),
    OnboardingInfo(
      title: "MANFAAT",
      descriptions:
          "SEPUh mengurangi beban administratif dengan otomatisasi penjadwalan dan manajemen informasi, memastikan layanan tepat waktu dan mengurangi waktu tunggu.",
      image: "assets/board3.png",
    ),
  ];
}
