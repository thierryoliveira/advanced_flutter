import 'dart:math';

import 'package:advanced_flutter/infra/api/clients/http_get_client.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

String anyString() => Random().nextInt(50000).toString();

final class ClientSpy extends Mock implements Client {}

final class HttpGetClientSpy extends Mock implements HttpGetClient {}
