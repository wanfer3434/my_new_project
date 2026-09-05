class MetricasModel {

  final int totalProductos;
  final double valorInventario;
  final int totalLeads;
  final int leadsHoy;
  final int bannersClicksTotal;


  MetricasModel({

    required this.totalProductos,

    required this.valorInventario,

    required this.totalLeads,

    required this.leadsHoy,

    required this.bannersClicksTotal,

  });



  factory MetricasModel.fromJson(Map<String,dynamic> json){


    return MetricasModel(

      totalProductos:
      json["total_productos"] ?? 0,


      valorInventario:
      (json["valor_inventario"] ?? 0).toDouble(),


      totalLeads:
      json["total_leads"] ?? 0,


      leadsHoy:
      json["leads_hoy"] ?? 0,


      bannersClicksTotal:
      json["banners_clicks_total"] ?? 0,

    );


  }


}