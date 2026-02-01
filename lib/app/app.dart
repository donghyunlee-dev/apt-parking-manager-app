class App extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Apt Parking Manager',
            theme: AppTheme.light,
            onGenerateRoute: AppRouter.onGenerateRoute,
        );
    }
}