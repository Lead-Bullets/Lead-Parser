
AttachScript(".\src\LeadParser\Ext\ObjectModule.bsl", "Parser");

XMLReader = New XMLReader;
XMLReader.OpenFile("C:\temp\RUERPNEW\Documents\ЗаказКлиента.xml");
x = XMLReader.Read(); // IgnoreXMLDeclaration?
x = XMLReader.Read(); // MetaDataObject
x = XMLReader.Read();

Parser = New Parser;
Kinds = Parser.Kinds();
Result = Parser.Parse(XMLReader, Kinds, Kinds.Document);

JSONWriter = New JSONWriter;
TempFileName = GetTempFileName(".json");
JSONWriter.OpenFile(TempFileName,,, New JSONWriterSettings(, Chars.Tab));
WriteJSON(JSONWriter, Result);
JSONWriter.Close();

TextReader = New TextReader(TempFileName, "UTF-8");
Message(TextReader.Read());

