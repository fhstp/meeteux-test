var tasks = [
    {"startDate":new Date("1450"),"endDate":new Date("1493"),"taskName":"1"},
    {"startDate":new Date("1468"),"endDate":new Date("1470"),"taskName":"2"},
    {"startDate":new Date("1470"),"endDate":new Date("1490"),"taskName":"2"},
    {"startDate":new Date("1507"),"endDate":new Date("1508"),"taskName":"1"}
    ];
    
   /* var taskStatus = {
        "SUCCEEDED" : "bar",
        "FAILED" : "bar-failed",
        "RUNNING" : "bar-running",
        "KILLED" : "bar-killed"
    };*/
    
    var taskNames = [ "1", "2"];
    
    tasks.sort(function(a, b) {
        return a.endDate - b.endDate;
    });
    var maxDate = new Date("1520");//tasks[tasks.length - 1].endDate;
    tasks.sort(function(a, b) {
        return a.startDate - b.startDate;
    });
    var minDate = new Date("1450");//tasks[0].startDate;
    
    var format = "%Y";
    var orientation = "vertical";
    
    var gantt = d3.gantt().taskTypes(taskNames).tickFormat(format).minDate(minDate).maxDate(maxDate).orientation(orientation);
    gantt(tasks);