import 'package:about/about.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'pubspec.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIos = theme.platform == TargetPlatform.iOS || theme.platform == TargetPlatform.macOS;

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());  // Mostrar un cargador mientras se obtienen los datos
        }

        final packageInfo = snapshot.data!;
        final aboutPage = AboutPage(
          values: {
            'version': packageInfo.version,
            'buildNumber': packageInfo.buildNumber,
            'year': DateTime.now().year.toString(),
            'author': Pubspec.authorsName.join(', '),
          },
          title: const Text(
            'Acerca de Zonix',
            style: TextStyle(
              // Aquí puedes ajustar el estilo del título
              fontSize: 24, // Ajusta el tamaño del texto si es necesario
              fontWeight: FontWeight.bold,
            ),
          ),
          applicationVersion: 'Versión ${packageInfo.version}, Build #${packageInfo.buildNumber}',
          applicationDescription: Text(
            getAppDescription(),
            textAlign: TextAlign.justify,
          ),
          applicationIcon: Container(
            margin: const EdgeInsets.only(bottom: -20), // Ajustar el margen inferior para reducir el espacio
            padding: const EdgeInsets.symmetric(vertical: -60), // Mantener un poco de padding vertical
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/splash_logo_dark.png'
                  : 'assets/images/splash_logo.png',
              width: 300,  // Ajusta el tamaño de la imagen según necesites
              height: 300,
            ),
          ),
          applicationLegalese: '© ${DateTime.now().year} ${Pubspec.authorsName.join(', ')}. Todos los derechos reservados.',
          children: const <Widget>[
            MarkdownPageListTile(
              filename: 'README.md',
              title: Text('Ver Readme'),
              icon: Icon(Icons.all_inclusive),
            ),
            MarkdownPageListTile(
              filename: 'CHANGELOG.md',
              title: Text('Ver Cambios'),
              icon: Icon(Icons.view_list),
            ),
            MarkdownPageListTile(
              filename: 'LICENSE.md',
              title: Text('Ver Licencia'),
              icon: Icon(Icons.description),
            ),
            MarkdownPageListTile(
              filename: 'CONTRIBUTING.md',
              title: Text('Contribuciones'),
              icon: Icon(Icons.share),
            ),
            MarkdownPageListTile(
              filename: 'CODE_OF_CONDUCT.md',
              title: Text('Código de Conducta'),
              icon: Icon(Icons.sentiment_satisfied),
            ),
            LicensesPageListTile(
              title: Text('Licencias de Código Abierto'),
              icon: Icon(Icons.favorite),
            ),
          ],
        );

        return isIos ? _buildCupertinoApp(aboutPage) : _buildMaterialApp(aboutPage);
      },
    );
  }

  Widget _buildMaterialApp(Widget aboutPage) {
    return MaterialApp(
      title: 'Acerca de Zonix',
      home: SafeArea(child: aboutPage),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }

  Widget _buildCupertinoApp(Widget aboutPage) {
    return CupertinoApp(
      title: 'Acerca de Zonix (Cupertino)',
      home: SafeArea(child: aboutPage),
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
    );
  }
}
