import 'dart:math';
import 'constants.dart';
import 'regular_expressions.dart';

String discontinuitiesHintText(int expressionsCount, String language) =>
    kDiscontinuitiesHintStartText[language] +
    functionGenerator([for (int i = 1; i <= expressionsCount; i++) 'x_$i(t)'],
        [for (int i = 1; i < expressionsCount; i++) 't_$i '], language) +
    kDiscontinuitiesHintEndText[language];

String piecesHintText(List<String> discontinuities, String language) =>
    kPiecesHintStartText[language] +
    functionGenerator(
        [for (int i = 1; i <= discontinuities.length + 1; i++) 'x_$i(t)'],
        discontinuities,
        language) +
    kPiecesHintEndText[language];

String windowHintText(List<String> expressions, List<String> discontinuities,
        String language) =>
    kWindowHintStartText[language] +
    functionGenerator(expressions, discontinuities, language);

String fourierSeriesResultText(
        {List<String> expressions,
        List<String> discontinuities,
        double start,
        double end,
        double rmsValue,
        String language}) =>
    kFourierSeriesResultStartText[language] +
    functionGenerator(expressions, discontinuities, language) +
    kFourierSeriesResultMiddleText[language] +
    start.toStringAsFixed(2) +
    r""",""" +
    end.toStringAsFixed(2) +
    r"""]$$$$T_0=""" +
    (end - start).toStringAsFixed(2) +
    r"""s\qquad \omega_0=""" +
    (2 * pi / (end - start)).toStringAsFixed(2) +
    r"""rad/s \quad s_{rms}= """ +
    rmsValue.toStringAsFixed(3) +
    r"""$$
     """;

String functionGenerator(
    List<String> expressions, List<String> discontinuities, String language) {
  String function;
  if (expressions.length == 1)
    function = r"""$$x(t)=""" + expressions[0] + r"""$$""";
  else {
    function = r"""$$ x(t) = \left\{
    \begin{array}{ll}  """ +
        expressions[0] +
        r"""  & \mbox{, """ +
        kIfText[language] +
        r""" } t \leq """ +
        discontinuities[0] +
        r"""s \\ """;
    for (int i = 1; i < expressions.length; i++)
      if (i == expressions.length - 1)
        function += expressions[i] +
            r"""  & \mbox{, """ +
            kIfText[language] +
            """ } t > """ +
            discontinuities[i - 1] +
            r"""s \end{array} \right. $$""";
      else
        function += expressions[i] +
            r"""  & \mbox{, """ +
            kIfText[language] +
            """ } """ +
            discontinuities[i - 1] +
            r"""s< t \leq """ +
            discontinuities[i] +
            r"""s \\ """;
  }
  return function;
}
