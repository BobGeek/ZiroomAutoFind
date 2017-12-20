%% 本程序用于爬取自如网页内满足条件房屋的状态变化
% 
% 作者：Bob_Geek
% 时间：20171220


%% 设置的参数
searchurl = 'http://www.ziroom.com/z/nl/z2-o1.html?qwd=';	%查找的 url
keyword = [{'蒲黄榆'},{'刘家窑'},{'宋家庄'},{'金港国际'}];      %关键字
pricemax = 2500;                                            %最大价格
pricemin = 1000;                                            %最小价格
mailto = [];                                                %接收邮箱  不用邮件功能请留空
% mailto = 'wangpeng214@126.com';                             %接收邮箱  不用邮件功能请留空
mailfrom = 'wangpeng214@126.com';                           %发送邮箱
mailpass = '123456789';                                   %发送邮箱密码
times = 1000;                                               %循环刷新次数


%% 主循环
while times > 0
    disp([datestr(now,'yyyy-mm-dd HH:MM:SS'),'--循环还剩',num2str(times),'次']);
    for keywordind = 1: length(keyword);
        lookforhome(keyword{keywordind},searchurl,pricemax,pricemin,mailto,mailfrom,mailpass); % 搜索的关键字
        pause(10)
    end
    times = times - 1;
end

