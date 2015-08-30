
function CommonUtils() { }
CommonUtils._path = '/selfservice/dwr';

CommonUtils.getBrowserName = function(callback) {
    DWREngine._execute(CommonUtils._path, 'CommonUtils', 'getBrowserName', false, callback);
}

CommonUtils.sendFeedbackSubmittedEmails = function(p0, p1, p2, p3, p4, p5, p6, p7, p8, callback) {
    DWREngine._execute(CommonUtils._path, 'CommonUtils', 'sendFeedbackSubmittedEmails', p0, p1, p2, p3, p4, p5, p6, p7, p8, callback);
}
