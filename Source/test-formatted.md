# Test

测试 $a$ 测试 $a$ 测试 $a$ 测试 $a$ 测试测试 $a$，测试 $a$，测试 $a$，测试 $a$，测试，$a$ 测试

magic-commented equation
<!-- MarkdownFormat-IEB-Off -->
测试$a$测试 $a$测试$a$ 测试 $a$ 测试测试$a$，测试 $a$，测试$a$ ，测试 $a$ ，测试，$a$测试
<!-- MarkdownFormat-IEB-Off -->

* 标度分析。半径应该正比于 $\frac{\hbar^2}{e^2 k m}$，基态能量应该正比于 $-\frac{e^4 k^2 m}{\hbar^2}$。

* 一些同学直接写下 $rp\sim \hbar$，这里可以进一步分析一下近似 $r\sim \sigma_x, p\sim \sigma_p$ 的原因。

    对于任意测试波函数，有

    \begin{equation}
        \bra{\phi}H\ket{\phi}
        =
        \bra{\phi}\frac{p^{2}}{2m}-\frac{k e^{2}}{r}\ket{\phi}
        \geq E_{0}
        .
    \end{equation}

    对于任意测试波函数，有

    \begin{equation}
        \bra{\phi}H\ket{\phi}
        =
        \bra{\phi}\frac{p^{2}}{2m}-\frac{k e^{2}}{r}\ket{\phi}
        \geq E_{0}
        .
    \end{equation}

    基态波函数 $\ket{\phi_{0}}$ 是球对称的，因此 $\bra{\phi_{0}}{\vp}\ket{\phi_{0}}=0 \implies \sigma_{p}^{2}=\bra{\phi_{0}}p^{2}\ket{\phi_{0}}$。我们需要的是对于类似于基态波函数的一类测试波函数，有

    \begin{equation}
        \bra{\phi_{0}}\frac{1}{r}\ket{\phi_{0}}\sim \frac{1}{\sigma_{r}}\sim \frac{\sigma_{p}}{\hbar}
        .
    \end{equation}

    在已知基态波函数的时候容易验证这是成立的。有兴趣的同学可以尝试如何建立类似的估计，或者直接构造一个好的测试波函数，进而得到 $E_{0}$ 的上界。
