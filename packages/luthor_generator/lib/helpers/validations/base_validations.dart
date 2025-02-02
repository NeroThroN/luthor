import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:luthor_generator/checkers.dart';
import 'package:luthor_generator/errors/unsupported_type_error.dart';
import 'package:luthor_generator/helpers/validations/string_validations.dart';
import 'package:source_gen/source_gen.dart';

String getValidations(ParameterElement param) {
  final buffer = StringBuffer();

  final isNullable = param.type.nullabilitySuffix == NullabilitySuffix.question;

  if (param.type.getDisplayString(withNullability: false) == 'DateTime') {
    throw UnsupportedTypeError(
      'DateTime is not supported. Use String instead with @isDateTime.',
    );
  }

  if (param.type.isDynamic) {
    buffer.write('l.any()');
  }

  if (param.type.isDartCoreBool) {
    buffer.write('l.bool()');
  }

  if (param.type.isDartCoreDouble) {
    buffer.write('l.double()');
  }

  if (param.type.isDartCoreInt) {
    buffer.write('l.int()');
  }

  if (param.type.isDartCoreList) {
    _writeListValidations(buffer, param);
  }

  if (param.type.isDartCoreNull) {
    buffer.write('l.nullValue()');
  }

  if (param.type.isDartCoreNum) {
    buffer.write('l.number()');
  }

  if (param.type.isDartCoreString) {
    buffer.write('l.string()');
    buffer.write(getStringValidations(param));
  }

  if (buffer.isEmpty) {
    _checkAndAddCustomSchema(buffer, param);
  }

  if (!param.type.isDynamic && !isNullable) buffer.write('.required()');

  return buffer.toString();
}

void _checkAndAddCustomSchema(StringBuffer buffer, ParameterElement param) {
  final element = param.type.element;
  if (element == null) {
    throw UnsupportedTypeError(
      'Cannot determine type of ${param.type.getDisplayString(withNullability: false)}',
    );
  }

  final hasLuthorAnnotation = getAnnotation(luthorChecker, element) != null;
  if (!hasLuthorAnnotation) {
    throw UnsupportedTypeError(
      'Type ${param.type.getDisplayString(withNullability: false)} '
      'does not have @luthor annotation.',
    );
  }
  buffer.write('${param.type.getDisplayString(withNullability: false)}.schema');
}

DartObject? getAnnotation(TypeChecker checker, Element field) {
  return checker.firstAnnotationOf(field);
}

void _writeListValidations(StringBuffer buffer, ParameterElement param) {
  buffer.write('l.list(validators: [');
  final listType = param.type
      .getDisplayString(withNullability: false)
      .replaceFirst('List<', '')
      .replaceFirst('>', '');

  const types = ['dynamic', 'bool', 'double', 'Null', 'int', 'num', 'String'];

  if (!types.contains(listType)) {
    throw UnsupportedTypeError('List<$listType> is not supported.');
  }

  if (listType == 'dynamic') {
    buffer.write('l.any()])');
    return;
  }

  if (listType == 'num') {
    buffer.write('l.number()])');
    return;
  }

  if (listType == 'Null') {
    buffer.write('l.nullValue()])');
    return;
  }

  buffer.write('l.${listType.toLowerCase()}()])');
}
