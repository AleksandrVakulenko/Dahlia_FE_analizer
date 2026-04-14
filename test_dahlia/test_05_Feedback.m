



Am = Dahlia('COM4');
%%

Am.Capacitor('150n');

%%

Am.cap_short(1)

%%

Am.switch_feedback_res(0, 'high')

%%

Am.switch_feedback_cap(1)

%%

Am.enable_feedback(1);


%%


Am.enable_feedback(0);


%%

delete(Am)


%%



Am.Capacitor('10p');
Am.cap_short(0)
Am.enable_feedback(1);

%%

Am.Capacitor('1n');
Am.cap_short(0)
Am.enable_feedback(1);

%%

Am.Capacitor('150n');
Am.cap_short(0)
Am.enable_feedback(1);

%%

Am.Capacitor('20u');
Am.cap_short(0)
Am.enable_feedback(1);
pause(1.5);

%%

Am.enable_feedback(0);
Am.cap_short(1)







%%

Am.switch_feedback_res(0, 'high')
Am.enable_feedback(1);

%%

Am.switch_feedback_res(1, 'high')
Am.enable_feedback(1);

%%

Am.switch_feedback_res(2, 'high')
Am.enable_feedback(1);

%%

Am.switch_feedback_res(3, 'high')
Am.enable_feedback(1);

%%

Am.enable_feedback(0);
Am.cap_short(1);




