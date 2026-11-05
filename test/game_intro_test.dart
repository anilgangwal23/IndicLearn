import 'package:flutter_test/flutter_test.dart';
import 'package:indic_learn/onboarding/game_intro.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('GameIntroStore remembers each handler once it is marked seen', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await GameIntroStore.loadSeen(), isEmpty);

    await GameIntroStore.markSeen('GamePage');
    await GameIntroStore.markSeen('GamePage');
    await GameIntroStore.markSeen('MemoryFlipPage');

    expect(await GameIntroStore.loadSeen(), {'GamePage', 'MemoryFlipPage'});
  });
}
