import 'package:flutter/material.dart';

import '../service/rust_api_chat_service.dart';



class BusinessCenterPage extends StatefulWidget {


  const BusinessCenterPage({super.key});


  @override
  State<BusinessCenterPage> createState() =>
      _BusinessCenterPageState();

}




class _BusinessCenterPageState
    extends State<BusinessCenterPage> {


  final RustApiChatService api =
  RustApiChatService();


  Map<String,dynamic>? metricas;


  bool error = false;



  @override
  void initState(){

    super.initState();

    cargarMetricas();

  }





  Future<void> cargarMetricas() async {


    try {


      final datos =
      await api.getMetricas();



      if(mounted){

        setState(() {

          metricas = datos;

          error = false;

        });

      }



    }catch(e){


      print(
          "Error cargando métricas: $e"
      );


      if(mounted){

        setState(() {

          error = true;

        });

      }

    }


  }




  @override
  void dispose(){


    api.dispose();


    super.dispose();

  }





  @override
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:
      const Color(0xffF5F6FA),



      body:SafeArea(


        child:RefreshIndicator(


          onRefresh:
          cargarMetricas,


          child:ListView(


            padding:
            const EdgeInsets.all(16),


            children:[



              _buildCompanyHeader(),



              const SizedBox(height:20),



              _buildTitle(
                  "Operaciones"
              ),




              GridView.count(


                crossAxisCount:2,


                shrinkWrap:true,


                physics:
                const NeverScrollableScrollPhysics(),



                children:[



                  BusinessCard(

                    icon:Icons.inventory,

                    title:"Inventario",

                    subtitle:"Productos y stock",

                  ),




                  BusinessCard(

                    icon:Icons.point_of_sale,

                    title:"Ventas",

                    subtitle:"Facturación diaria",

                  ),





                  BusinessCard(

                    icon:Icons.people,

                    title:"Clientes",

                    subtitle:"Base de clientes",

                  ),




                  BusinessCard(

                    icon:Icons.bar_chart,

                    title:"Reportes",

                    subtitle:"Estadísticas",

                  ),



                ],


              ),




              const SizedBox(height:20),




              _buildTitle(
                  "Inteligencia del negocio"
              ),




              BusinessActionCard(


                icon:
                Icons.smart_toy,


                title:
                "TwinYogo IA",


                description:
                "Analiza ventas, recomienda compras y detecta oportunidades.",


              ),





              const SizedBox(height:20),




              _buildTitle(
                  "Administración"
              ),





              BusinessActionCard(


                icon:
                Icons.settings,


                title:
                "Configuración empresa",


                description:
                "Usuarios, plan, permisos y datos del negocio.",


              ),



            ],


          ),


        ),


      ),


    );


  }






  Widget _buildCompanyHeader(){



    final productos =
        metricas?["total_productos"] ?? 0;



    final inventario =
        metricas?["valor_inventario"] ?? 0;



    final leads =
        metricas?["total_leads"] ?? 0;



    final clicks =
        metricas?["banners_clicks_total"] ?? 0;





    return Container(



      padding:
      const EdgeInsets.all(20),




      decoration:
      BoxDecoration(



        borderRadius:
        BorderRadius.circular(20),




        gradient:
        const LinearGradient(


          colors:[

            Colors.indigo,

            Colors.blueAccent

          ],


        ),


      ),




      child:Column(



        crossAxisAlignment:
        CrossAxisAlignment.start,



        children:[




          const Text(


            "🏢 Mi Empresa",



            style:
            TextStyle(


              color:Colors.white,


              fontSize:22,


              fontWeight:
              FontWeight.bold,


            ),


          ),




          const SizedBox(height:10),





          const Text(



            "Plan Profesional",



            style:
            TextStyle(



              color:
              Colors.white70,



              fontSize:15,


            ),



          ),





          const SizedBox(height:20),





          if(error)

            const Text(

              "❌ Error conectando API",

              style:
              TextStyle(

                color:Colors.white,

              ),

            )

          else if(metricas == null)


            const Text(

              "Cargando datos...",

              style:
              TextStyle(

                color:Colors.white,

              ),

            )

          else


            Column(


              crossAxisAlignment:
              CrossAxisAlignment.start,



              children:[



                _metric(

                  Icons.inventory,

                  "Productos",

                  productos.toString(),

                ),




                _metric(

                  Icons.attach_money,

                  "Inventario",

                  "\$${inventario.toStringAsFixed(0)}",

                ),





                _metric(

                  Icons.people,

                  "Leads",

                  leads.toString(),

                ),





                _metric(

                  Icons.ads_click,

                  "Clicks banners",

                  clicks.toString(),

                ),



              ],


            )




        ],


      ),



    );



  }







  Widget _metric(

      IconData icon,

      String titulo,

      String valor

      ){



    return Padding(


      padding:
      const EdgeInsets.only(bottom:8),



      child:Row(



        children:[



          Icon(

            icon,

            color:Colors.white,

            size:20,

          ),




          const SizedBox(width:8),




          Text(

            "$titulo: $valor",

            style:
            const TextStyle(

              color:Colors.white,

              fontSize:16,

            ),

          )



        ],


      ),


    );


  }







  Widget _buildTitle(String text){


    return Padding(


      padding:
      const EdgeInsets.only(bottom:10),



      child:Text(



        text,



        style:
        const TextStyle(



          fontSize:20,

          fontWeight:
          FontWeight.bold,



        ),


      ),


    );


  }



}







class BusinessCard extends StatelessWidget{


  final IconData icon;

  final String title;

  final String subtitle;




  const BusinessCard({


    super.key,


    required this.icon,


    required this.title,


    required this.subtitle,


  });





  @override
  Widget build(BuildContext context){



    return Card(



      margin:
      const EdgeInsets.all(6),



      child:
      Padding(



        padding:
        const EdgeInsets.all(15),




        child:Column(



          mainAxisAlignment:
          MainAxisAlignment.center,



          children:[



            Icon(

              icon,

              size:35,

              color:Colors.indigo,

            ),



            const SizedBox(height:10),




            Text(

              title,

              style:
              const TextStyle(

                fontWeight:
                FontWeight.bold,

                fontSize:16,

              ),

            ),





            Text(

              subtitle,

              textAlign:
              TextAlign.center,


              style:
              const TextStyle(

                fontSize:12,

              ),

            )



          ],


        ),


      ),


    );

  }


}







class BusinessActionCard extends StatelessWidget{


  final IconData icon;

  final String title;

  final String description;




  const BusinessActionCard({


    super.key,


    required this.icon,


    required this.title,


    required this.description,


  });




  @override
  Widget build(BuildContext context){


    return Card(



      child:
      ListTile(



        leading:
        CircleAvatar(


          child:
          Icon(icon),


        ),




        title:
        Text(title),




        subtitle:
        Text(description),




        trailing:
        const Icon(
            Icons.arrow_forward_ios
        ),



      ),


    );


  }



}