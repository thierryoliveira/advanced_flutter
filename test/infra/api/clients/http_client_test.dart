import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

class HttpClient {
  final Client client;

  HttpClient({required this.client});

  Future<void> get({
    required String url,
    Map<String, String>? headers,
    Map<String, String?>? params,
  }) async {
    final requestHeaders = {
      'content-type': 'application/json',
      'accept': 'application/json',
      ...?headers,
    };
    final uri = _buildUri(url: url, params: params);

    await client.get(uri, headers: requestHeaders);
  }

  Uri _buildUri({required String url, Map<String, String?>? params}) {
    params?.forEach(
      (key, value) => url = url.replaceFirst(':$key', value ?? ''),
    );

    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return Uri.parse(url);
  }
}

void main() {
  late Client client;
  late HttpClient sut;
  late String url;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  When<Future<Response>> mockClient() =>
      when(() => client.get(any(), headers: any(named: 'headers')));

  setUp(() {
    client = ClientSpy();
    sut = HttpClient(client: client);
    url = anyString();

    mockClient().thenAnswer((_) async => Response('', 200));
  });

  group('GET method:', () {
    test('should request using the correct method', () async {
      await sut.get(url: '');
      verify(() => client.get(any(), headers: any(named: 'headers'))).called(1);
    });

    test('should request with the correct URL', () async {
      await sut.get(url: url);
      verify(() => client.get(Uri.parse(url), headers: any(named: 'headers')));
    });

    test('should request with default headers when none is provided', () async {
      await sut.get(url: url);
      verify(
        () => client.get(
          any(),
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
          },
        ),
      ).called(1);
    });

    test(
      'should request with the correct headers appending the default when custom headers are provided',
      () async {
        await sut.get(url: url, headers: {'h1': 'header1', 'h2': 'header2'});
        verify(
          () => client.get(
            any(),
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
              'h1': 'header1',
              'h2': 'header2',
            },
          ),
        ).called(1);
      },
    );

    test('should request with correct params', () async {
      url = 'http://anyurl.com/:param1/:param2';
      await sut.get(url: url, params: {'param1': 'value1', 'param2': 'value2'});

      verify(
        () => client.get(
          Uri.parse('http://anyurl.com/value1/value2'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('should request with correct optional params', () async {
      url = 'http://anyurl.com/:param1/:param2';
      await sut.get(url: url, params: {'param1': 'value1', 'param2': null});

      verify(
        () => client.get(
          Uri.parse('http://anyurl.com/value1'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });
  });
}
