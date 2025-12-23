D = 1;
DT = 0.006;

sig = sqrt(2*D*DT);

p = 0.999;

%factor 2 comes from Brownian motion as the characteristic length is
%sqrt(D*DT) instead of sqrt(2*D*DT).
quant = @(s,p) s*sqrt(2 * -2*log(1 - p));

q_slope = sqrt(2 * -2*log(1 - p));
E_slope = sqrt(pi);
display(sprintf('%g quantile slope = %.2f', p, q_slope));
display(sprintf('E slope = %.2f', E_slope));
display(sprintf('Ratio q/E slopes = %.2f', q_slope / E_slope))

pause(1)
figure
pause(1)
hold on
plot(sqrt(D*(0:0.001:1)), quant(sqrt(D*(0:0.001:1)), p), 'LineWidth', 2) %99.9 quantile
plot(sqrt(D*(0:0.001:1)), sqrt(D*(0:0.001:1) * pi), 'b', 'LineWidth', 2) %mean
plot(sqrt(D*(0:0.001:1)), sqrt(2 * D*(0:0.001:1)), 'm', 'LineWidth', 2) %mode
plot(sqrt(0.1*0.001), quant(sqrt(0.1*0.001), p), '*r')
plot(sqrt(1*0.006), quant(sqrt(1*0.006), p), '*r')
plot(sqrt(10*0.1), quant(sqrt(10*0.1), p), '*r')
hold off
axis square
xlabel('sqrt(D*DT) (µm)')
ylabel('Displacement length (µm)')
pause(1)
print('/tmp/D_rayleigh_distrib_characs.svg', '-dsvg')
pause(1)