import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

class HttpClient {
  final Client client;

  HttpClient({required this.client});

  Future<void> get({required String url}) async {
    await client.get(Uri.parse(url));
  }
}

void main() {
  late Client client;
  late HttpClient sut;
  late String url;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    client = ClientSpy();
    sut = HttpClient(client: client);
    url = anyString();

    when(() => client.get(any())).thenAnswer((_) async => Response('', 200));
  });

  group('GET method:', () {
    test('should request using the correct method', () async {
      await sut.get(url: '');
      verify(() => client.get(any())).called(1);
    });

    test('should request with the correct URL', () async {
      await sut.get(url: url);
      verify(() => client.get(Uri.parse(url)));
    });
  });
}
