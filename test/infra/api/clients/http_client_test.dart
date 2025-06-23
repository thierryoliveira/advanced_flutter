import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

class HttpClient {
  final Client client;

  HttpClient({required this.client});

  Future<void> get() async {
    await client.get(Uri());
  }
}

void main() {
  late Client client;
  late HttpClient sut;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    client = ClientSpy();
    sut = HttpClient(client: client);

    when(() => client.get(any())).thenAnswer((_) async => Response('', 200));
  });

  group('GET method:', () {
    test('should request using the correct method', () async {
      await sut.get();
      verify(() => client.get(any())).called(1);
    });
  });
}
