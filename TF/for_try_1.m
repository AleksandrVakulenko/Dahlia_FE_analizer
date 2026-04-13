


w = 10.^linspace(-5, 5, 100);

s = 1i*w;
TF1 = (1.041e-6*s + 1.889e-9) ./ (s.^2 + 924.8*s + 6964);
TF2 = TF1./(1i*s);

figure
subplot(2, 1, 1)
plot(w, abs(TF2))
yline(150e-12)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')

subplot(2, 1, 2)
plot(w, angle(TF2)/pi*180)
yline(-90)
set(gca, 'xscale', 'log')
% set(gca, 'yscale', 'log')











