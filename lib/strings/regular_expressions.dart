const kA0 = r'a_0 = \frac{2}{T_0} \int_{T_0} x(t) dt';
const kAn = r'a_n = \frac{2}{T_0} \int_{T_0} x(t) cos(n \omega_0 t) dt';
const kBn = r'b_n = \frac{2}{T_0} \int_{T_0} x(t) sin(n \omega_0 t) dt';
const kSF =
    r's(t) = \frac{a_0}{2} + \sum^{\infty}_{n=1}[ a_n cos(n \omega_0 t) + b_n sin({n \omega_0 t})]';
const kw0 = r'\omega_0 = \frac{2 \pi}{T_0}';

const kEquationsTitle = {
  'pt': 'Equações',
  'en': 'Equations',
};

const kHistoryTitle = {
  'pt': 'História',
  'en': 'History',
};

const kHistoryText = {
  'pt':
      r'''A Série de Fourier é uma forma de série trigonométrica usada para representar funções infinitas e periódicas complexas dos processos físicos, na forma de senos e cossenos. Simplificando a visualização e manipulação de funções complexas. Foi criada em 1807 por Jean Baptiste Joseph Fourier (1768-1830).''',
  'en':
      r'''The Fourier Series is a form of trigonometric series used to represent infinite functions and complex periodic physical processes, in the form of sines and cosines. Simplifying the visualization and manipulation of complex functions. It was created in 1807 by Jean Baptiste Joseph Fourier (1768-1830).''',
};
const kUtilizationTitle = {
  'pt': r'Utilização',
  'en': r'Utility',
};
const kUtilizationText = {
  'pt':
      r'''A Série de Fourier é importante na técnica de compactação digital, como por exemplo: para reproduzir músicas digitais por streaming, para ver imagens online de rápido carregamento, e no cancelamento de ruído nos fones de ouvido.''',
  'en':
      '''The Fourier Series is important in the digital compression technique, for example: to play digital music via streaming,
 for fast loading online images, and noise canceling on headphones.'''
};

//   'pt':
//       r"""<p><B>História</B></p><p> </p>
//   <p><B>Equacionamento</B></p><p>
// <p>A forma geral da série é:</p>
//
// $$s(t) = {a_0 \over 2} + \sum_{n=1}^{\infty}\Big[ a_n cos(n \omega_0 t) + b_n sin({n \omega_0 t})\Big]$$
// <p>Onde \(T_0\) é o período fundamental, e \(\omega_0\) é a frequência angular dada por:</p>
// $$\omega_0 = \frac{2 \pi}{T_0}$$
// <p>
// Os termos \(a_0\), \(a_n\) e \(b_n\) são números que variam de acordo com a função que será representada.
//  São as amplitudes de cada onda em série, que são calculados com as seguintes equações:
//  $$a_0 = \frac{2}{T_0} \int_{T_0} x(t) dt$$
//  $$a_n = \frac{2}{T_0} \int_{T_0} x(t) \cdot{} cos(n \omega_0 t) dt$$
//  $$b_n = \frac{2}{T_0} \int_{T_0} x(t) \cdot{} sin(n \omega_0 t) dt$$
//  <p>
//  <p>O intervalo de integração \(T_0\) é abitrário. Geralmente os limitantes são \(-T_0 \over 2\) e \(T_0 \over 2\) para tirar proveito da simetria.
//  <p><B>Utilização</B></p><p>
//  <p></p><br>""",
//   'en':
//       r"""<p><B>History</B></p><p></p>
//   <p><B>Equation</B></p><p>
// <p>The general form of the series is:</p>
//
// $$s(t) = {a_0 \over 2} + \sum_{n=1}^{\infty}\Big[ a_n cos(n \omega_0 t) + b_n sin({n \omega_0 t})\Big]$$
// <p>Where \(T_0\) is the fundamental period, and \(omega_0\) is an angular frequency given by:</p>
// $$\omega_0 = \frac{2 \pi}{T_0}$$
// <p>
// The terms \(a_0\), \(a_n\) and \(b_n\) are numbers that vary according to the function that will be represented.
//  It is the amplitudes of each wave in series, which are calculated with the following equations:
//  $$a_0 = \frac{2}{T_0} \int_{T_0} x(t) dt$$
//  $$a_n = \frac{2}{T_0} \int_{T_0} x(t) \cdot{} cos(n \omega_0 t) dt$$
//  $$b_n = \frac{2}{T_0} \int_{T_0} x(t) \cdot{} sin(n \omega_0 t) dt$$
//  <p>
//  <p>
// The integration interval \(T_0\) is abitrary. Generally, the limiters are \(- T_0 \over 2\) and \(T_0 \over 2\) to take advantage of symmetry.
//  <p><B>Utility</B>
//  <p></p><br>"""
// };

const kDiscontinuitiesHintText = {
  'pt': r"""<p> Entre a quantidade de <B>sentenças</B> de \(x(t)\):
 <p> Observe exemplos de funções: 
 $$h(t) = sin(2 \pi t)$$
  $$U(t) = \left\{ \begin{array}{ll} 0  & \mbox{, se } t < 0 \\
      1/2 & \mbox{, se } t = 0 \\
    1 & \mbox{, se } t > 0 \end{array} \right.$$
   <p>\(U(t)\) - também conhecido como <B>Degrau Unitário</B> ou <B>Heaviside</B> - é definida por 3 sentenças.  </p>
    """,
  'en': r"""<p> Enter the <B>pieces number</B> of \(x(t)\):
 <p> Watch these examples: 
 $$h(t) = sin(2 \pi t)$$
  $$U(t) = \left\{ \begin{array}{ll} 0  & \mbox{, if } t < 0 \\
      1/2 & \mbox{, if } t = 0 \\
    1 & \mbox{, if } t > 0 \end{array} \right.$$
   <p> \(U(t)\) - as known as <B>Unit Step</B> or <B>Heaviside</B> - is defined by 3 pieces.  </p>
    """
};

const kDiscontinuitiesHintStartText = {
  'pt': r""" Entre com os valores das <B>descontinuidades</B> de \(x(t)\):""",
  'en': r""" Enter the <B>discontinuities</B> values of \(x(t)\):""",
};
const kDiscontinuitiesHintEndText = {
  'pt': r"""  <p><B>Atenção:</B>
          <p>\(\cdot{}\)Os valores devem estar em ordem crescente;        
          <p>\(\cdot{}\)Expressões numéricas são válidas, como: pi^2, sqrt(2), e/2, etc.""",
  'en': r"""  <p><B>Attention:</B>
          <p>\(\cdot{}\)The values must be in ascending order;        
          <p>\(\cdot{}\)Numeric expressions are valid, like: pi^2, sqrt(2), e/2, etc."""
};

const kPiecesHintStartText = {
  'pt': r""" Entre com as sentenças de \(x(t)\):""",
  'en': r""" Enter the pieces of \(x(t)\):"""
};
const kPiecesHintEndText = {
  'pt': r"""
       <p><B>Atenção:</B>
          <p>\(\cdot{}\)A função não pode resultar em \(\pm\) \(\infty\) 
          ou em <B>valores complexos</B>.""",
  'en': r"""
       <p><B>Attention:</B>
          <p>\(\cdot{}\)The function can't result \(\pm\) \(\infty\) 
          or <B>complex values</B>."""
};

const kWindowHintStartText = {
  'pt':
      r"""Com \(x(t)\) definida, escolha a <B>janela de tempo</B> em que \(s(t)\) irá representar \(x(t)\):""",
  'en':
      r"""With \(x(t)\) defined, choose the <B>time window</B> in which \(s(t)\) will represent \(x(t)\):"""
};

const kFourierSeriesResultStartText = {
  'pt': r"""<B> Função original \(x(t)\)</B>:""",
  'en': r"""<B> Original Function \(x(t)\)</B>:"""
};
const kFourierSeriesResultMiddleText = {
  'pt': r""" <p> <B>Função da Série \(s(t)\)</B>:
    $$s(t) \approx x(t) \quad \forall t \in [ """,
  'en': r""" <p> <B>Series Function \(s(t)\)</B>:
    $$s(t) \approx x(t) \quad \forall t \in [ """,
};
