import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:certame3_angel_salinas/utils/paleta_colores.dart';
import 'package:certame3_angel_salinas/utils/peticion.dart';

class PeticionesPage extends StatelessWidget {
  const PeticionesPage({super.key});
  //Aqui se colocan todas las peticiones de los usuarios, esta manda la peticion al usuario que se mando la peticion
  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    final peticiones = usuario == null
        ? <Peticion>[]
        : PeticionesLocales.peticiones.where((peticion) {
            final destinatarioUid = peticion.destinatarioUid;
            if (destinatarioUid != null && destinatarioUid.isNotEmpty) {
              return destinatarioUid == usuario.uid;
            }

            final destinatarioCorreo = peticion.destinatarioCorreo
                ?.trim()
                .toLowerCase();
            return destinatarioCorreo != null &&
                destinatarioCorreo.isNotEmpty &&
                destinatarioCorreo == usuario.email?.trim().toLowerCase();
          }).toList();

    return Scaffold(
      backgroundColor: PaletaColores.fondo,
      appBar: AppBar(
        backgroundColor: PaletaColores.superficie,
        foregroundColor: PaletaColores.primarioOscuro,
        title: Text('Peticiones'),
      ),
      //esta dice que si no hay peticiones manda un mensaje al centro que no hay, si hay peticiones coloca un card con el titulo del objeto
      //el autor que mando la peticion y el autor al que le llego la peticion, con un mensaje explicando
      body: peticiones.isEmpty
          ? Center(child: Text('Aún no hay peticiones'))
          : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: peticiones.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final peticion = peticiones[index];
                return Card(
                  color: PaletaColores.blanco,
                  child: ListTile(
                    leading: Icon(
                      MdiIcons.messageTextOutline,
                      color: PaletaColores.primario,
                    ),
                    title: Text(peticion.tituloObjeto),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('De: ${peticion.remitente}'),
                        if (peticion.autorObjeto != null)
                          Text('Autor: ${peticion.autorObjeto}'),
                        SizedBox(height: 4),
                        Text(peticion.descripcion),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
