import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo_mock_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  test('Mocked SharedPreferences returns stored values', () async {
    final mockPrefs = MockSharedPreferences();

    when(mockPrefs.getStringList('todoList')).thenReturn(['{"task": "Mocked Task", "isChecked": false}']);

    List<String>? result = mockPrefs.getStringList('todoList');
    expect(result, isNotNull);
    expect(result![0], '{"task": "Mocked Task", "isChecked": false}');
  });
}
