import 'package:material_ui/material_ui.dart';

class EditarPublicacionDialog extends StatefulWidget {
  const EditarPublicacionDialog({super.key, required this.estadoActual});

  final String estadoActual;

  @override
  State<EditarPublicacionDialog> createState() =>
      _EditarPublicacionDialogState();
}

class _EditarPublicacionDialogState extends State<EditarPublicacionDialog> {
  late String _estado;

  @override
  void initState() {
    super.initState();
    _estado = widget.estadoActual;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar estado'),
      content: DropdownButtonFormField<String>(
        initialValue: _estado,
        decoration: InputDecoration(labelText: 'Estado'),
        items: [
          DropdownMenuItem(value: 'Vigente', child: Text('Vigente')),
          DropdownMenuItem(value: 'Devuelto', child: Text('Devuelto')),
        ],
        onChanged: (value) {
          if (value != null) setState(() => _estado = value);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _estado),
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
