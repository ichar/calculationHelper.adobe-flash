 
function writeToFile(title, file, text) { 
    try {
        alert(title+': '+file);

        var fso = new ActiveXObject("Scripting.FileSystemObject");
        var a = fso.CreateTextFile(file, true);
        a.WriteLine(text.replace(/>\t/g, '>\r\n\t'));
        a.Close();

        alert('OK');
    } 
    catch (e) { 
        alert('error:'+e['description']); 
    }
}