import 'dart:math';

import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

String anyString() => Random().nextInt(50000).toString();

class HttpClientSpy extends Mock implements Client {}
