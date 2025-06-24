import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/infra/api/adapters/http_adapter.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

void main() {
  late Client client;
  late HttpAdapter sut;
  late String url;
  const basicJson = '{"key1": "value1", "key2": "value2"}';

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  When<Future<Response>> mockClient() =>
      when(() => client.get(any(), headers: any(named: 'headers')));

  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client: client);
    url = anyString();

    mockClient().thenAnswer((_) async => Response(basicJson, 200));
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

    test('should request ignoring invalid params', () async {
      url = 'http://anyurl.com/:param1/:param2';
      await sut.get(url: url, params: {'param3': 'value3'});

      verify(
        () => client.get(
          Uri.parse('http://anyurl.com/:param1/:param2'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('should request ignoring query strings', () async {
      await sut.get(
        url: url,
        queryString: {'queryParam1': 'value1', 'queryParam2': 'value2'},
      );

      verify(
        () => client.get(
          Uri.parse('$url?queryParam1=value1&queryParam2=value2'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('should request ignoring query strings and params', () async {
      url = 'http://anyurl.com/:param3/:param4';

      await sut.get(
        url: url,
        params: {'param3': 'value3', 'param4': 'value4'},
        queryString: {'queryParam1': 'value1', 'queryParam2': 'value2'},
      );

      verify(
        () => client.get(
          Uri.parse(
            'http://anyurl.com/value3/value4?queryParam1=value1&queryParam2=value2',
          ),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('should throw UnexpectedError on 400', () async {
      mockClient().thenAnswer((_) async => Response('', 400));
      final future = sut.get(url: url);
      expect(future, throwsA(isA<UnexpectedError>()));
    });

    test('should throw SessionExpiredError on 401', () async {
      mockClient().thenAnswer((_) async => Response('', 401));
      final future = sut.get(url: url);
      expect(future, throwsA(isA<SessionExpiredError>()));
    });

    test('should throw UnexpectedError on 403', () async {
      mockClient().thenAnswer((_) async => Response('', 403));
      final future = sut.get(url: url);
      expect(future, throwsA(isA<UnexpectedError>()));
    });

    test('should throw UnexpectedError on 404', () async {
      mockClient().thenAnswer((_) async => Response('', 404));
      final future = sut.get(url: url);
      expect(future, throwsA(isA<UnexpectedError>()));
    });

    test('should throw UnexpectedError on 500', () async {
      mockClient().thenAnswer((_) async => Response('', 500));
      final future = sut.get(url: url);
      expect(future, throwsA(isA<UnexpectedError>()));
    });

    test('should return a Map when successful', () async {
      final data = await sut.get<Json>(url: url);
      expect(data, isA<Map>());
      expect(data?['key1'], 'value1');
      expect(data?['key2'], 'value2');
    });

    test('should return an Array of Map when successful', () async {
      final jsonList = '[$basicJson, {"key3": "value3"}]';
      mockClient().thenAnswer((_) async => Response(jsonList, 200));
      final data = await sut.get(url: url);
      expect(data, isA<List>());
      expect(data[0]['key1'], 'value1');
      expect(data[0]['key2'], 'value2');
      expect(data[1]['key3'], 'value3');
    });

    test('should return an Map containing a List when successful', () async {
      final jsonList = '''
        {
            "key1": "value1",
            "key2": [
                {
                    "key": "value1"
                },
                {
                    "key": "value2"
                }
            ]
        }
      ''';
      mockClient().thenAnswer((_) async => Response(jsonList, 200));
      final data = await sut.get(url: url);
      expect(data, isA<Map>());
      expect(data['key1'], 'value1');
      expect(data['key2'], isA<List>());
      expect(data['key2'][0]['key'], 'value1');
      expect(data['key2'][1]['key'], 'value2');
    });

    test('should return null on 200 with empty response', () async {
      mockClient().thenAnswer((_) async => Response('', 200));
      final data = await sut.get(url: url);
      expect(data, isNull);
    });

    test('should return null on 204', () async {
      mockClient().thenAnswer((_) async => Response('', 204));
      final data = await sut.get(url: url);
      expect(data, isNull);
    });
  });
}
