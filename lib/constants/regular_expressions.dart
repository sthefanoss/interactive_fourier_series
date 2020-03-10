

const kIntroText = r"""<p><B>História</B></p><p> A Série de Fourier é uma forma de série trigonométrica usada para representar funções infinitas
 e periódicas complexas dos processos físicos, na forma de senos e cossenos.
 Simplificando a visualização e manipulação de funções complexas.
  Foi criada em 1807 por Jean Baptiste Joseph Fourier (1768-1830).</p>
  <p><B>Equacionamento</B></p><p>
<p>A forma geral da série é:</p>

$$T(t) = {a_0 \over 2} + \sum_{n=1}^{\infty}\Big[ a_n cos(n \omega_0 t) + b_n sin({n \omega_0 t})\Big]$$
<p>Onde \(T_0\) é o período fundamental, e \(\omega_0\) é a frequência angular dada por:</p>
$$\omega_0 = \frac{2 \pi}{T_0}$$
<p>
Os termos \(a_0\), \(a_n\) e \(b_n\) são números que variam de acordo com a função que será representada.
 São as amplitudes de cada onda em série, que são calculados com as seguintes equações:
 $$a_0 = \frac{2}{T_0} \int_{T_0} f(t) dt$$
 $$a_n = \frac{2}{T_0} \int_{T_0} f(t) \cdot{} cos(n \omega_0 t) dt$$
 $$b_n = \frac{2}{T_0} \int_{T_0} f(t) \cdot{} sin(n \omega_0 t) dt$$
 <p>
 <p>O intervalo de integração \(T_0\) é abitrário. Geralmente os limitantes são \(-T_0 \over 2\) e \(T_0 \over 2\) para tirar proveito da simetria.
 <p><B>Utilização</B></p><p>
 <p>A Série de Fourier é importante na técnica de compactação digital, como por exemplo: para reproduzir músicas digitais por streaming, 
 para ver imagens online de rápido carregamento, e no cancelamento de ruído nos fones de ouvido.</p><br>""";

const kDescontinuidadesTex = r"""<p> Entre a quantidade de <B>sentenças</B> da função \(f(t)\).
 <p> Observe exemplos de funções: 
 $$h(t) = sen(2 \pi t)$$
  $$U(t) = \left\{ \begin{array}{ll} 0  & \mbox{se } t < 0 \\
      1/2 & \mbox{se } t = 0 \\
    1 & \mbox{se } t > 0 \end{array} \right.$$
   <p>Note que \(U(t)\) - também conhecido como <B>Degrau Unitário</B> ou <B>Heaviside</B> - é definido em três sentenças, enquanto que a função \(h(t)\) é apenas em uma.  </p>
    """;

