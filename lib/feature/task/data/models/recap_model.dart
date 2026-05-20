import 'dart:convert';

RecapModel recapModelFromJson(String str) =>
    RecapModel.fromJson(jsonDecode(str));

class RecapModel {
  final int totalKontribusi;
  final int totalProyek;
  final List<ChartData> chartData;

  RecapModel({
    required this.totalKontribusi,
    required this.totalProyek,
    required this.chartData,
  });

  factory RecapModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return RecapModel(
      totalKontribusi: data['total_kontribusi'] ?? 0,
      totalProyek: data['total_proyek'] ?? 0,
      chartData: (data['chart_data'] as List? ?? [])
          .map((e) => ChartData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'total_kontribusi': totalKontribusi,
    'total_proyek': totalProyek,
    'chart_data': chartData.map((e) => e.toMap()).toList(),
  };
}

class ChartData {
  final String label;
  final int value;

  ChartData({required this.label, required this.value});

  factory ChartData.fromJson(Map<String, dynamic> json) =>
      ChartData(label: json['label'] ?? '', value: json['value'] ?? 0);

  Map<String, dynamic> toMap() => {'label': label, 'value': value};
}
