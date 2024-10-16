     body: Center(
        child: _selectedLevel == 1
            ? const OtherScreen() // Cambia a la pantalla de Other si se selecciona el nivel 1
            : Center(child: Text('Contenido del nivel $_selectedLevel')),
      ),