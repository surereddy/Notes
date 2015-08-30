
function DocHistoryUtils() { }
DocHistoryUtils._path = '/selfservice/dwr';

DocHistoryUtils.insertDocFeedback = function(p0, callback) {
    DWREngine._execute(DocHistoryUtils._path, 'DocHistoryUtils', 'insertDocFeedback', p0, callback);
}
