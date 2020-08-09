import 'package:flutter/material.dart';

const _supportedLanguages = ['pt', 'en'];
String getLocationCode(BuildContext context) {
  final language = Localizations.localeOf(context).languageCode;
  return _supportedLanguages.contains(language) ? language : 'en';
}

const kIfText = {
  'pt': 'se',
  'en': 'if',
};

const kAppName = {
  'pt': r'Séries de Fourier Interativas',
  'en': r'Interactive Fourier Series',
};
const kCalculatorInputName = {
  'pt': r'Calculadora Gráfica',
  'en': r'Graphing Calculator'
};
const kCalculatorResultName = {'pt': r'Resultado', 'en': r'Result'};

const kHelpText = {'pt': r'Ajuda', 'en': r'Help'};

const kBackText = {'pt': r'Voltar', 'en': r'Back'};

const kForwardText = {'pt': r'Avançar', 'en': r'Forward'};

const kPiecesNumberText = {
  'pt': r'Número de Sentenças',
  'en': r'Pieces Number'
};

const kDiscontinuitiesText = {
  'pt': r'Descontinuidades',
  'en': r'Discontinuities',
};

const kIntroductionText = {
  'pt': r'Introdução',
  'en': r'Introduction',
};

const kExamplesText = {
  'pt': r'Exemplos',
  'en': r'Examples',
};

const kNewChartText = {
  'pt': r'Novo Gráfico',
  'en': r'New Chart',
};

const kInvalidExpressionText = {
  'pt': r'Expressão Inválida',
  'en': r'Invalid Expression'
};

const kPiecesOfFtText = {
  'pt': r'Sentenças de x(t)',
  'en': r'Pieces of x(t)',
};

const kInvalidTExpressionText = {
  'pt': r'Expressão de t inválida',
  'en': r'Invalid t Expression',
};

const kWindowingText = {
  'pt': r'Enjanelamento',
  'en': r'Windowing',
};

const kInvalidOrderTitleText = {
  'pt': r'Ordem Inválida',
  'en': r'Invalid Order',
};

const kInvalidOrderContentText = {
  'pt': r'As descontinuidades não estão em ordem crescente!',
  'en': r'The discontinuities must be in ascending order!'
};

const kInputDataText = {
  'pt': r'Dados da Entrada',
  'en': r'Input Data',
};

const kTFGraphsText = {
  'pt': r'Gráficos de x(t) e s(t)',
  'en': r'Graphs for x(t) and s(t)'
};

const kTFilteredText = {
  'pt': r'Gráficos de s(t) filtrado',
  'en': 'Graph for Filtered s(t)'
};

const kFrequencySpectrumText = {
  'pt': r'Espectro de Frequência S(ω)',
  'en': 'Frequency Spectrum S(ω)'
};

const kViewChartText = {'pt': r'Ver Tabela', 'en': 'See Chart'};

const kFrequencyChartTitleText = {
  'pt': r'Tabela de Espectro de Frequência',
  'en': 'Frequency Spectrum Chart'
};

const kBothText = {'pt': r'Ambos', 'en': r'Both'};

const kWaitingForCalculationText = {
  'pt': 'Calculando Termos.\n Aguarde, por favor.',
  'en': 'Processing.\nPlease wait.'
};

const kWaitingForRenderingText = {
  'pt': 'Renderizando Texto.\nAguarde, por favor.',
  'en': 'Rendering Text. \nPlease wait.'
};

const kRenderingIntroductionText = {
  'pt': 'Renderizando Introdução.\nAguarde, por favor.',
  'en': 'Rendering Introduction.\nPlease wait.'
};

const kChangeBoundsText = {
  'pt': r'Mudar Limites',
  'en': r'Change Bounds',
};

const kDefault = {'pt': r'Padrão', 'en': r'Default'};

const kAccept = {'pt': r'Aceitar', 'en': r'Accept'};
const kChangeBoundsErrorText = {
  'pt': r'Início deve ser menor que fim!',
  'en': r'Start must be before end!'
};
const kStartText = {'pt': r'Começo', 'en': r'Start'};
const kEndText = {'pt': r'Fim', 'en': r'End'};
const kDevelopedBy = 'Sthefano Schiavon';
const kGMail = 'sthefanoss@gmail.com';
const kThanksTo = {'pt': 'Agradecimentos', 'en': 'Thanks to'};
const kStudentOf = {
  'pt': 'Estudante de Engenharia Elétrica',
  'en': 'Electrical Engineering Student'
};
const kThirdPartyLibs = {
  'pt': 'Bibliotecas de Terceiros',
  'en': 'Third Party Libraries'
};