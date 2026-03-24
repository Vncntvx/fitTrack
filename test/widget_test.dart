import 'package:flutter_test/flutter_test.dart';

import 'package:fittrack/app.dart';
import 'package:fittrack/core/router/app_router.dart';

void main() {
  test('App wiring smoke test', () {
    expect(() => const WorkoutTrackerApp(), returnsNormally);
    expect(appRouter.configuration.routes, isNotEmpty);
    expect(appRouter.routeInformationParser, isNotNull);
    expect(appRouter.routerDelegate, isNotNull);
  });
}
