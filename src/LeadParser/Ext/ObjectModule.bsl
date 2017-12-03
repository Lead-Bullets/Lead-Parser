﻿
#Region Parser

Function Parse(XMLReader, Kinds, Kind, ReadToMap = False) Export
	//While TypeOf(Kind) = Type("String") Do
	//	Kind = Kinds[Kind];
	//EndDo;
	Data = Undefined;
	If TypeOf(Kind) = Type("Map") Then
		Data = ParseRecord(XMLReader, Kinds, Kind, ReadToMap);
	ElsIf TypeOf(Kind) = Type("Structure") Then
		Data = ParseObject(XMLReader, Kinds, Kind, ReadToMap);
	Else
		XMLReader.Read(); // node val | node end
		If XMLReader.NodeType <> XMLNodeType.EndElement Then
			If TypeOf(Kind) = Type("TypeDescription") Then // basic
				Data = Kind.AdjustValue(XMLReader.Value);
			Else // enum
				Data = Kind[XMLReader.Value];
			EndIf;
			XMLReader.Read(); // node end
		EndIf;
	EndIf;
	Return Data;
EndFunction // Parse()

Function ParseRecord(XMLReader, Kinds, Kind, ReadToMap)
	Object = ?(ReadToMap, New Map, New Structure);
	While XMLReader.ReadAttribute() Do
		AttributeName = XMLReader.LocalName;
		AttributeKind = Kind[AttributeName];
		If AttributeKind <> Undefined Then
			Object.Insert(AttributeName, AttributeKind.AdjustValue(XMLReader.Value));
		EndIf;
	EndDo;
	While XMLReader.Read() // node beg | parent end | none
		And XMLReader.NodeType = XMLNodeType.StartElement Do
		PropertyName = XMLReader.LocalName;
		PropertyKind = Kind[PropertyName];
		If PropertyKind = Undefined Then
			XMLReader.Skip();
		Else
			Object.Insert(PropertyName, Parse(XMLReader, Kinds, PropertyKind, ReadToMap));
		EndIf;
	EndDo;
	If XMLReader.NodeType = XMLNodeType.Text Then
		PropertyName = "_"; // noname
		PropertyKind = Kind[PropertyName];
		If PropertyKind <> Undefined Then
			Object.Insert(PropertyName, PropertyKind.AdjustValue(XMLReader.Value));
		EndIf;
		XMLReader.Read(); // node end
	EndIf;
	Return Object;
EndFunction // ParseRecord()

Function ParseObject(XMLReader, Kinds, Kind, ReadToMap)
	Items = Kind.Items;
	Data = ?(ReadToMap, New Map, New Structure);
	For Each Item In Items Do
		Data.Insert(Item.Key, New Array);
	EndDo;
	While XMLReader.Read() // node beg | parent end | none
		And XMLReader.NodeType = XMLNodeType.StartElement Do
		ItemName = XMLReader.LocalName;
		ItemKind = Items[ItemName];
		If ItemKind = Undefined Then
			XMLReader.Skip(); // node end
		Else
			Data[ItemName].Add(Parse(XMLReader, Kinds, ItemKind, ReadToMap));
		EndIf;
	EndDo;
	Return Data;
EndFunction // ParseObject()

#EndRegion // Parser

#Region Kinds

Function Kinds() Export

	Kinds = New Structure;

	// basic
	Kinds.Insert("String", New TypeDescription("String"));
	Kinds.Insert("Boolean", New TypeDescription("Boolean"));
	Kinds.Insert("Decimal", New TypeDescription("Number"));
	Kinds.Insert("UUID", "String");

	// simple
	Kinds.Insert("MDObjectRef", "String");
	Kinds.Insert("MDMethodRef", "String");
	Kinds.Insert("FieldRef", "String");
	Kinds.Insert("DataPath", "String");
	Kinds.Insert("IncludeInCommandCategoriesType", "String");

	// common
	Kinds.Insert("LocalStringType", LocalStringType());
	Kinds.Insert("MDListType", MDListType());
	Kinds.Insert("FieldList", FieldList());
	Kinds.Insert("ChoiceParameterLinks", ChoiceParameterLinks());
	Kinds.Insert("TypeLink", TypeLink());
	Kinds.Insert("StandardAttributes", StandardAttributes());
	Kinds.Insert("StandardTabularSections", StandardTabularSections());
	Kinds.Insert("Characteristics", Characteristics());
	Kinds.Insert("AccountingFlag", AccountingFlag());
	Kinds.Insert("ExtDimensionAccountingFlag", ExtDimensionAccountingFlag());
	Kinds.Insert("AddressingAttribute", AddressingAttribute());

	// metadata objects
	Kinds.Insert("MetaDataObject",             MetaDataObject());	
	Kinds.Insert("Attribute",                  Attribute());
	Kinds.Insert("Dimension",                  Dimension());
	Kinds.Insert("Resource",                   Resource());
	Kinds.Insert("TabularSection",             TabularSection());
	Kinds.Insert("Command",                    Command());	
	Kinds.Insert("Configuration",              Configuration());
	Kinds.Insert("Language",                   Language());
	Kinds.Insert("AccountingRegister",         AccountingRegister());
	Kinds.Insert("AccumulationRegister",       AccumulationRegister());
	Kinds.Insert("BusinessProcess",            BusinessProcess());
	Kinds.Insert("CalculationRegister",        CalculationRegister());
	Kinds.Insert("Catalog",                    Catalog());
	Kinds.Insert("ChartOfAccounts",            ChartOfAccounts());
	Kinds.Insert("ChartOfCalculationTypes",    ChartOfCalculationTypes());
	Kinds.Insert("ChartOfCharacteristicTypes", ChartOfCharacteristicTypes());
	Kinds.Insert("CommandGroup",               CommandGroup());
	Kinds.Insert("CommonAttribute",            CommonAttribute());
	Kinds.Insert("CommonCommand",              CommonCommand());
	Kinds.Insert("CommonForm",                 CommonForm());
	Kinds.Insert("CommonModule",               CommonModule());
	Kinds.Insert("CommonPicture",              CommonPicture());
	Kinds.Insert("CommonTemplate",             CommonTemplate());
	Kinds.Insert("Constant",                   Constant());
	Kinds.Insert("DataProcessor",              DataProcessor());
	Kinds.Insert("DocumentJournal",            DocumentJournal());
	Kinds.Insert("DocumentNumerator",          DocumentNumerator());
	Kinds.Insert("Document",                   Document());
	Kinds.Insert("Enum",                       Enum());
	Kinds.Insert("EventSubscription",          EventSubscription());
	Kinds.Insert("ExchangePlan",               ExchangePlan());
	Kinds.Insert("FilterCriterion",            FilterCriterion());
	Kinds.Insert("FunctionalOption",           FunctionalOption());
	Kinds.Insert("FunctionalOptionsParameter", FunctionalOptionsParameter());
	Kinds.Insert("HTTPService",                HTTPService());
	Kinds.Insert("InformationRegister",        InformationRegister());
	Kinds.Insert("Report",                     Report());
	Kinds.Insert("Role",                       Role());
	Kinds.Insert("ScheduledJob",               ScheduledJob());
	Kinds.Insert("Sequence",                   Sequence());
	Kinds.Insert("SessionParameter",           SessionParameter());
	Kinds.Insert("SettingsStorage",            SettingsStorage());
	Kinds.Insert("Subsystem",                  Subsystem());
	Kinds.Insert("Task",                       Task());
	Kinds.Insert("Template",                   Template());
	Kinds.Insert("WebService",                 WebService());
	Kinds.Insert("WSReference",                WSReference());
	Kinds.Insert("XDTOPackage",                XDTOPackage());
	Kinds.Insert("Form",                       Form());
	
	// logform
	Kinds.Insert("LogForm", LogForm());
	Kinds.Insert("FormChildItems", FormChildItems());

	Resolve(Kinds, Kinds);

	Return Kinds;

EndFunction // Kinds()

Procedure Resolve(Kinds, Object)
	For Each Item In Object Do
		If TypeOf(Item.Value) = Type("String") Then
			Object[Item.Key] = Kinds[Item.Value]
		ElsIf TypeOf(Item.Value) = Type("Map")
			Or TypeOf(Item.Value) = Type("Structure") Then
			Resolve(Kinds, Item.Value);
		EndIf;
	EndDo;
EndProcedure // Resolve()

Function Record(Base = Undefined)
	Record = New Map;
	If Base <> Undefined Then
		For Each Item In Base Do
			Record[Item.Key] = Item.Value;
		EndDo;
	EndIf;
	Return Record;
EndFunction // Record()

Function Object(Base = Undefined)
	Object = New Structure("Items", New Map);
	If Base <> Undefined Then
		For Each Item In Base.Items Do
			Object.Items.Add(Item);
		EndDo;
	EndIf;
	Return Object;
EndFunction // Object()

#EndRegion // Kinds

#Region Common

Function LocalStringType()
	This = Object();
	Items = This.Items;
	Items["item"] = LocalStringTypeItem();
	Return This;
EndFunction // LocalStringType()

Function LocalStringTypeItem()
	This = Record();
	This["lang"] = "String";
	This["content"] = "String";
	Return This
EndFunction // LocalStringTypeItem()

Function MDListType()
	This = Object();
	Items = This.Items;
	Items["Item"] = MDListTypeItem();
	Return This;
EndFunction // MDListType()

Function MDListTypeItem()
	This = Record();
	This["type"] = "String";
	This["_"] = "String";
	Return This
EndFunction // MDListTypeItem()

Function FieldList()
	This = Object();
	Items = This.Items;
	Items["Field"] = FieldListItem();
	Return This;
EndFunction // FieldList()

Function FieldListItem()
	This = Record();
	This["type"] = "String";
	This["_"] = "String";
	Return This
EndFunction // FieldListItem()

Function ChoiceParameterLinks()
	This = Object();
	Items = This.Items;
	Items["Link"] = ChoiceParameterLink();
	Return This;
EndFunction // ChoiceParameterLinks()

Function ChoiceParameterLink()
	This = Record();
	This["Name"] = "String";
	This["DataPath"] = "String";
	This["ValueChange"] = Enums.LinkedValueChangeMode;
	Return This;
EndFunction // ChoiceParameterLink()

Function TypeLink() // todo: check
	This = Record();
	This["DataPath"] = "DataPath";
	This["LinkItem"] = "Decimal";
	This["ValueChange"] = Enums.LinkedValueChangeMode;
	Return This;
EndFunction // TypeLink()

Function StandardAttributes()
	This = Object();
	Items = This.Items;
	Items["StandardAttribute"] = StandardAttribute();
	Return This;
EndFunction // StandardAttributes()

Function StandardAttribute()
	This = Record();
	This["name"]                  = "String";
	This["Synonym"]               = "LocalStringType";
	This["Comment"]               = "String";
	This["ToolTip"]               = "LocalStringType";
	This["QuickChoice"]           = Enums.UseQuickChoice;
	This["FillChecking"]          = Enums.FillChecking;
	//This["FillValue"]             = ;
	This["FillFromFillingValue"]  = Enums.Boolean;
	This["ChoiceParameterLinks"]  = "ChoiceParameterLinks";
	//This["ChoiceParameters"]      = ;
	This["LinkByType"]            = "TypeLink";
	This["FullTextSearch"]        = Enums.FullTextSearchUsing;
	This["PasswordMode"]          = Enums.Boolean;
	This["DataHistory"]           = Enums.DataHistoryUse;
	This["Format"]                = "LocalStringType";
	This["EditFormat"]            = "LocalStringType";
	This["Mask"]                  = "String";
	This["MultiLine"]             = Enums.Boolean;
	This["ExtendedEdit"]          = Enums.Boolean;
	//This["MinValue"]              = ;
	//This["MaxValue"]              = ;
	This["MarkNegatives"]         = Enums.Boolean;
	This["ChoiceForm"]            = "MDObjectRef";
	This["CreateOnInput"]         = Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"]  = Enums.ChoiceHistoryOnInput;
	Return This;
EndFunction // StandardAttribute()

Function StandardTabularSections()
	This = Object();
	Items = This.Items;
	Items["StandardTabularSection"] = StandardTabularSection();
	Return This;
EndFunction // StandardTabularSections()

Function StandardTabularSection()
	This = Record();
	This["name"]                = "String";
	This["Synonym"]             = "LocalStringType";
	This["Comment"]             = "String";
	This["ToolTip"]             = "LocalStringType";
	This["FillChecking"]        = Enums.FillChecking;
	This["StandardAttributes"]  = "StandardAttributes";
	Return This;
EndFunction // StandardTabularSection()

Function Characteristics()
	This = Object();
	Items = This.Items;
	Items["Characteristic"] = Characteristic();
	Return This;
EndFunction // Characteristics()

Function Characteristic()
	This = Record();
	This["CharacteristicTypes"] = CharacteristicTypes();
	This["CharacteristicValues"] = CharacteristicValues();
	Return This;
EndFunction // Characteristic()

Function CharacteristicTypes()
	This = Record();
	This["from"] = "MDObjectRef";
	This["KeyField"] = "FieldRef";
	This["TypesFilterField"] = "FieldRef";
	//This["TypesFilterValue"] = ;
	Return This;
EndFunction // CharacteristicTypes()

Function CharacteristicValues()
	This = Record();
	This["from"] = "MDObjectRef";
	This["ObjectField"] = "FieldRef";
	This["TypeField"] = "FieldRef";
	//This["ValueField"] = ;
	Return This;
EndFunction // CharacteristicValues()

#EndRegion // Common

#Region MetaDataObject

Function MetaDataObject()
	This = Record();
	This["version"] = "Decimal";
	This["Configuration"]               = Configuration();
	This["Language"]                    = Language();
	This["AccountingRegister"]          = AccountingRegister();
	This["AccumulationRegister"]        = AccumulationRegister();
	This["BusinessProcess"]             = BusinessProcess();
	This["CalculationRegister"]         = CalculationRegister();
	This["Catalog"]                     = Catalog();
	This["ChartOfAccounts"]             = ChartOfAccounts();
	This["ChartOfCalculationTypes"]     = ChartOfCalculationTypes();
	This["ChartOfCharacteristicTypes"]  = ChartOfCharacteristicTypes();
	This["CommandGroup"]                = CommandGroup();
	This["CommonAttribute"]             = CommonAttribute();
	This["CommonCommand"]               = CommonCommand();
	This["CommonForm"]                  = CommonForm();
	This["CommonModule"]                = CommonModule();
	This["CommonPicture"]               = CommonPicture();
	This["CommonTemplate"]              = CommonTemplate();
	This["Constant"]                    = Constant();
	This["DataProcessor"]               = DataProcessor();
	This["DocumentJournal"]             = DocumentJournal();
	This["DocumentNumerator"]           = DocumentNumerator();
	This["Document"]                    = Document();
	This["Enum"]                        = Enum();
	This["EventSubscription"]           = EventSubscription();
	This["ExchangePlan"]                = ExchangePlan();
	This["FilterCriterion"]             = FilterCriterion();
	This["FunctionalOption"]            = FunctionalOption();
	This["FunctionalOptionsParameter"]  = FunctionalOptionsParameter();
	This["HTTPService"]                 = HTTPService();
	This["InformationRegister"]         = InformationRegister();
	This["Report"]                      = Report();
	This["Role"]                        = Role();
	This["ScheduledJob"]                = ScheduledJob();
	This["Sequence"]                    = Sequence();
	This["SessionParameter"]            = SessionParameter();
	This["SettingsStorage"]             = SettingsStorage();
	This["Subsystem"]                   = Subsystem();
	This["Task"]                        = Task();
	This["Template"]                    = Template();
	This["WebService"]                  = WebService();
	This["WSReference"]                 = WSReference();
	This["XDTOPackage"]                 = XDTOPackage();
	This["Form"]                        = Form();
	Return This;
EndFunction // MetaDataObject()

Function MDObjectBase()
	This = Record();
	This["uuid"] = "UUID";
	//This["InternalInfo"] = InternalInfo();
	Return This;
EndFunction // MDObjectBase()

#Region ChildObjects

#Region Attribute

Function Attribute()
	This = Record(MDObjectBase());
	This["Properties"] = AttributeProperties();
	Return This;
EndFunction // Attribute()

Function AttributeProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	//This["Type"]                   = "TypeDescription";
	This["PasswordMode"]           = Enums.Boolean;
	This["Format"]                 = "LocalStringType";
	This["EditFormat"]             = "LocalStringType";
	This["ToolTip"]                = "LocalStringType";
	This["MarkNegatives"]          = Enums.Boolean;
	This["Mask"]                   = "String";
	This["MultiLine"]              = Enums.Boolean;
	This["ExtendedEdit"]           = Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillFromFillingValue"]   = Enums.Boolean;
	//This["FillValue"]              = ;
	This["FillChecking"]           = Enums.FillChecking;
	This["ChoiceFoldersAndItems"]  = Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"]   = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"]            = Enums.UseQuickChoice;
	This["CreateOnInput"]          = Enums.CreateOnInput;
	This["ChoiceForm"]             = "MDObjectRef";
	This["LinkByType"]             = "TypeLink";
	This["ChoiceHistoryOnInput"]   = Enums.ChoiceHistoryOnInput;
	This["Indexing"]               = Enums.Indexing;
	This["FullTextSearch"]         = Enums.FullTextSearchUsing;
	This["Use"]                    = Enums.AttributeUse;
	This["ScheduleLink"]           = "MDObjectRef";
	This["DataHistory"]            = Enums.DataHistoryUse;
	Return This;
EndFunction // AttributeProperties()

#EndRegion // Attribute

#Region Dimension

Function Dimension()
	This = Record(MDObjectBase());
	This["Properties"] = DimensionProperties();
	Return This;
EndFunction // Dimension()

Function DimensionProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	//This["Type"]                   = "TypeDescription";
	This["PasswordMode"]           = Enums.Boolean;
	This["Format"]                 = "LocalStringType";
	This["EditFormat"]             = "LocalStringType";
	This["ToolTip"]                = "LocalStringType";
	This["MarkNegatives"]          = Enums.Boolean;
	This["Mask"]                   = "String";
	This["MultiLine"]              = Enums.Boolean;
	This["ExtendedEdit"]           = Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillChecking"]           = Enums.FillChecking;
	This["ChoiceFoldersAndItems"]  = Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"]   = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"]            = Enums.UseQuickChoice;
	This["CreateOnInput"]          = Enums.CreateOnInput;
	This["ChoiceForm"]             = "MDObjectRef";
	This["LinkByType"]             = "TypeLink";
	This["ChoiceHistoryOnInput"]   = Enums.ChoiceHistoryOnInput;
	This["Balance"]                = Enums.Boolean;
	This["AccountingFlag"]         = "MDObjectRef";
	This["DenyIncompleteValues"]   = Enums.Boolean;
	This["Indexing"]               = Enums.Indexing;
	This["FullTextSearch"]         = Enums.FullTextSearchUsing;
	This["UseInTotals"]            = Enums.Boolean;
	This["RegisterDimension"]      = "MDObjectRef";
	This["LeadingRegisterData"]    = "MDListType";
	This["FillFromFillingValue"]   = Enums.Boolean;
	//This["FillValue"]              = ;
	This["Master"]                 = Enums.Boolean;
	This["MainFilter"]             = Enums.Boolean;
	This["BaseDimension"]          = Enums.Boolean;
	This["ScheduleLink"]           = "MDObjectRef";
	This["DocumentMap"]            = "MDListType";
	This["RegisterRecordsMap"]     = "MDListType";
	This["DataHistory"]            = Enums.DataHistoryUse;
	Return This;
EndFunction // DimensionProperties()

#EndRegion // Dimension

#Region Resource

Function Resource()
	This = Record(MDObjectBase());
	This["Properties"] = ResourceProperties();
	Return This;
EndFunction // Resource()

Function ResourceProperties()
	This = Record();
	This["Name"]                        = "String";
	This["Synonym"]                     = "LocalStringType";
	This["Comment"]                     = "String";
	//This["Type"]                        = "TypeDescription";
	This["PasswordMode"]                = Enums.Boolean;
	This["Format"]                      = "LocalStringType";
	This["EditFormat"]                  = "LocalStringType";
	This["ToolTip"]                     = "LocalStringType";
	This["MarkNegatives"]               = Enums.Boolean;
	This["Mask"]                        = "String";
	This["MultiLine"]                   = Enums.Boolean;
	This["ExtendedEdit"]                = Enums.Boolean;
	//This["MinValue"]                    = ;
	//This["MaxValue"]                    = ;
	This["FillChecking"]                = Enums.FillChecking;
	This["ChoiceFoldersAndItems"]       = Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"]        = "ChoiceParameterLinks";
	//This["ChoiceParameters"]            = ;
	This["QuickChoice"]                 = Enums.UseQuickChoice;
	This["CreateOnInput"]               = Enums.CreateOnInput;
	This["ChoiceForm"]                  = "MDObjectRef";
	This["LinkByType"]                  = "TypeLink";
	This["ChoiceHistoryOnInput"]        = Enums.ChoiceHistoryOnInput;
	This["FullTextSearch"]              = Enums.FullTextSearchUsing;
	This["Balance"]                     = Enums.Boolean;
	This["AccountingFlag"]              = "MDObjectRef";
	This["ExtDimensionAccountingFlag"]  = "MDObjectRef";
	This["NameInDataSource"]            = "String";
	This["FillFromFillingValue"]        = Enums.Boolean;
	//This["FillValue"]                   = ;
	This["Indexing"]                    = Enums.Indexing;
	This["DataHistory"]                 = Enums.DataHistoryUse;
	Return This;
EndFunction // ResourceProperties()

#EndRegion // Resource

#Region AccountingFlag

Function AccountingFlag()
	This = Record(MDObjectBase());
	This["Properties"] = AccountingFlagProperties();
	Return This;
EndFunction // AccountingFlag()

Function AccountingFlagProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	//This["Type"]                   = "TypeDescription";
	This["PasswordMode"]           = Enums.Boolean;
	This["Format"]                 = "LocalStringType";
	This["EditFormat"]             = "LocalStringType";
	This["ToolTip"]                = "LocalStringType";
	This["MarkNegatives"]          = Enums.Boolean;
	This["Mask"]                   = "String";
	This["MultiLine"]              = Enums.Boolean;
	This["ExtendedEdit"]           = Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillFromFillingValue"]   = Enums.Boolean;
	//This["FillValue"]              = ;
	This["FillChecking"]           = Enums.FillChecking;
	This["ChoiceFoldersAndItems"]  = Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"]   = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"]            = Enums.UseQuickChoice;
	This["CreateOnInput"]          = Enums.CreateOnInput;
	This["ChoiceForm"]             = "MDObjectRef";
	This["LinkByType"]             = "TypeLink";
	This["ChoiceHistoryOnInput"]   = Enums.ChoiceHistoryOnInput;
	Return This;
EndFunction // AccountingFlagProperties()

#EndRegion // AccountingFlag

#Region ExtDimensionAccountingFlag

Function ExtDimensionAccountingFlag()
	This = Record(MDObjectBase());
	This["Properties"] = ExtDimensionAccountingFlagProperties();
	Return This;
EndFunction // ExtDimensionAccountingFlag()

Function ExtDimensionAccountingFlagProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	//This["Type"]                   = "TypeDescription";
	This["PasswordMode"]           = Enums.Boolean;
	This["Format"]                 = "LocalStringType";
	This["EditFormat"]             = "LocalStringType";
	This["ToolTip"]                = "LocalStringType";
	This["MarkNegatives"]          = Enums.Boolean;
	This["Mask"]                   = "String";
	This["MultiLine"]              = Enums.Boolean;
	This["ExtendedEdit"]           = Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillFromFillingValue"]   = Enums.Boolean;
	//This["FillValue"]              = ;
	This["FillChecking"]           = Enums.FillChecking;
	This["ChoiceFoldersAndItems"]  = Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"]   = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"]            = Enums.UseQuickChoice;
	This["CreateOnInput"]          = Enums.CreateOnInput;
	This["ChoiceForm"]             = "MDObjectRef";
	This["LinkByType"]             = "TypeLink";
	This["ChoiceHistoryOnInput"]   = Enums.ChoiceHistoryOnInput;
	Return This;
EndFunction // ExtDimensionAccountingFlagProperties()

#EndRegion // ExtDimensionAccountingFlag

#Region Column

Function Column()
	This = Record(MDObjectBase());
	This["Properties"] = ColumnProperties();
	Return This;
EndFunction // Column()

Function ColumnProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	This["Indexing"]               = Enums.Indexing;
	This["References"]             = "MDListType";
	Return This;
EndFunction // ColumnProperties()

#EndRegion // Column

#Region EnumValue

Function EnumValue()
	This = Record(MDObjectBase());
	This["Properties"] = EnumValueProperties();
	Return This;
EndFunction // EnumValue()

Function EnumValueProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	Return This;
EndFunction // EnumValueProperties()

#EndRegion // EnumValue

#Region Form

Function Form()
	This = Record(MDObjectBase());
	This["Properties"] = FormProperties();
	Return This;
EndFunction // Form()

Function FormProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	This["FormType"]               = Enums.FormType;
	This["IncludeHelpInContents"]  = Enums.Boolean;
	//This["UsePurposes"]            = "FixedArray";
	This["ExtendedPresentation"]   = "LocalStringType";
	Return This;
EndFunction // FormProperties()

#EndRegion // Form

#Region Template

Function Template()
	This = Record(MDObjectBase());
	This["Properties"] = TemplateProperties();
	Return This;
EndFunction // Template()

Function TemplateProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	This["TemplateType"]           = Enums.TemplateType;
	Return This;
EndFunction // TemplateProperties()

#EndRegion // Template

#Region AddressingAttribute

Function AddressingAttribute()
	This = Record(MDObjectBase());
	This["Properties"] = AddressingAttributeProperties();
	Return This;
EndFunction // AddressingAttribute()

Function AddressingAttributeProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	//This["Type"]                   = "TypeDescription";
	This["PasswordMode"]           = Enums.Boolean;
	This["Format"]                 = "LocalStringType";
	This["EditFormat"]             = "LocalStringType";
	This["ToolTip"]                = "LocalStringType";
	This["MarkNegatives"]          = Enums.Boolean;
	This["Mask"]                   = "String";
	This["MultiLine"]              = Enums.Boolean;
	This["ExtendedEdit"]           = Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillFromFillingValue"]   = Enums.Boolean;
	//This["FillValue"]              = ;
	This["FillChecking"]           = Enums.FillChecking;
	This["ChoiceFoldersAndItems"]  = Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"]   = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"]            = Enums.UseQuickChoice;
	This["CreateOnInput"]          = Enums.CreateOnInput;
	This["ChoiceForm"]             = "MDObjectRef";
	This["LinkByType"]             = "TypeLink";
	This["ChoiceHistoryOnInput"]   = Enums.ChoiceHistoryOnInput;
	This["Indexing"]               = Enums.Indexing;
	This["AddressingDimension"]    = "MDObjectRef";
	This["FullTextSearch"]         = Enums.FullTextSearchUsing;
	Return This;
EndFunction // AddressingAttributeProperties()

#EndRegion // AddressingAttribute

#Region TabularSection

Function TabularSection()
	This = Record(MDObjectBase());
	This["Properties"] = TabularSectionProperties();
	This["ChildObjects"] = TabularSectionChildObjects();
	Return This;
EndFunction // TabularSection()

Function TabularSectionProperties()
	This = Record();
	This["Name"]                = "String";
	This["Synonym"]             = "LocalStringType";
	This["Comment"]             = "String";
	This["ToolTip"]             = "LocalStringType";
	This["FillChecking"]        = Enums.FillChecking;
	This["StandardAttributes"]  = "StandardAttributes";
	This["Use"]                 = Enums.AttributeUse;
	Return This;
EndFunction // TabularSectionProperties()

Function TabularSectionChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"] = "Attribute";
	Return This;
EndFunction // TabularSectionChildObjects()

#EndRegion // TabularSection

#Region Command

Function Command()
	This = Record(MDObjectBase());
	This["Properties"] = CommandProperties();
	Return This;
EndFunction // Command()

Function CommandProperties()
	This = Record();
	This["Name"]                  = "String";
	This["Synonym"]               = "LocalStringType";
	This["Comment"]               = "String";
	This["Group"]                 = "IncludeInCommandCategoriesType";
	//This["CommandParameterType"]  = "TypeDescription";
	This["ParameterUseMode"]      = Enums.CommandParameterUseMode;
	This["ModifiesData"]          = Enums.Boolean;
	This["Representation"]        = Enums.ButtonRepresentation;
	This["ToolTip"]               = "LocalStringType";
	//This["Picture"]               = ;
	//This["Shortcut"]              = ;
	Return This;
EndFunction // CommandProperties()

#EndRegion // Command

#EndRegion // ChildObjects

#Region Configuration

Function Configuration()
	This = Record(MDObjectBase());
	This["Properties"] = ConfigurationProperties();
	This["ChildObjects"] = ConfigurationChildObjects();
	Return This;
EndFunction // Configuration()

Function ConfigurationProperties()
	This = Record();
	This["Name"]                                             = "String";
	This["Synonym"]                                          = "LocalStringType";
	This["Comment"]                                          = "String";
	This["NamePrefix"]                                       = "String";
	This["ConfigurationExtensionCompatibilityMode"]          = Enums.CompatibilityMode;
	This["DefaultRunMode"]                                   = Enums.ClientRunMode;
	//This["UsePurposes"]                                      = "FixedArray";
	This["ScriptVariant"]                                    = Enums.ScriptVariant;
	This["DefaultRoles"]                                     = "MDListType";
	This["Vendor"]                                           = "String";
	This["Version"]                                          = "String";
	This["UpdateCatalogAddress"]                             = "String";
	This["IncludeHelpInContents"]                            = Enums.Boolean;
	This["UseManagedFormInOrdinaryApplication"]              = Enums.Boolean;
	This["UseOrdinaryFormInManagedApplication"]              = Enums.Boolean;
	This["AdditionalFullTextSearchDictionaries"]             = "MDListType";
	This["CommonSettingsStorage"]                            = "MDObjectRef";
	This["ReportsUserSettingsStorage"]                       = "MDObjectRef";
	This["ReportsVariantsStorage"]                           = "MDObjectRef";
	This["FormDataSettingsStorage"]                          = "MDObjectRef";
	This["DynamicListsUserSettingsStorage"]                  = "MDObjectRef";
	This["Content"]                                          = "MDListType";
	This["DefaultReportForm"]                                = "MDObjectRef";
	This["DefaultReportVariantForm"]                         = "MDObjectRef";
	This["DefaultReportSettingsForm"]                        = "MDObjectRef";
	This["DefaultDynamicListSettingsForm"]                   = "MDObjectRef";
	This["DefaultSearchForm"]                                = "MDObjectRef";
	//This["RequiredMobileApplicationPermissions"]             = "FixedMap";
	This["MainClientApplicationWindowMode"]                  = Enums.MainClientApplicationWindowMode;
	This["DefaultInterface"]                                 = "MDObjectRef";
	This["DefaultStyle"]                                     = "MDObjectRef";
	This["DefaultLanguage"]                                  = "MDObjectRef";
	This["BriefInformation"]                                 = "LocalStringType";
	This["DetailedInformation"]                              = "LocalStringType";
	This["Copyright"]                                        = "LocalStringType";
	This["VendorInformationAddress"]                         = "LocalStringType";
	This["ConfigurationInformationAddress"]                  = "LocalStringType";
	This["DataLockControlMode"]                              = Enums.DefaultDataLockControlMode;
	This["ObjectAutonumerationMode"]                         = Enums.ObjectAutonumerationMode;
	This["ModalityUseMode"]                                  = Enums.ModalityUseMode;
	This["SynchronousPlatformExtensionAndAddInCallUseMode"]  = Enums.SynchronousPlatformExtensionAndAddInCallUseMode;
	This["InterfaceCompatibilityMode"]                       = Enums.InterfaceCompatibilityMode;
	This["CompatibilityMode"]                                = Enums.CompatibilityMode;
	This["DefaultConstantsForm"]                             = "MDObjectRef";
	Return This;
EndFunction // ConfigurationProperties()

Function ConfigurationChildObjects()
	This = Object();
	Items = This.Items;
	Items["Language"]                    = "String";
	Items["Subsystem"]                   = "String";
	Items["StyleItem"]                   = "String";
	Items["Style"]                       = "String";
	Items["CommonPicture"]               = "String";
	Items["Interface"]                   = "String";
	Items["SessionParameter"]            = "String";
	Items["Role"]                        = "String";
	Items["CommonTemplate"]              = "String";
	Items["FilterCriterion"]             = "String";
	Items["CommonModule"]                = "String";
	Items["CommonAttribute"]             = "String";
	Items["ExchangePlan"]                = "String";
	Items["XDTOPackage"]                 = "String";
	Items["WebService"]                  = "String";
	Items["HTTPService"]                 = "String";
	Items["WSReference"]                 = "String";
	Items["EventSubscription"]           = "String";
	Items["ScheduledJob"]                = "String";
	Items["SettingsStorage"]             = "String";
	Items["FunctionalOption"]            = "String";
	Items["FunctionalOptionsParameter"]  = "String";
	Items["DefinedType"]                 = "String";
	Items["CommonCommand"]               = "String";
	Items["CommandGroup"]                = "String";
	Items["Constant"]                    = "String";
	Items["CommonForm"]                  = "String";
	Items["Catalog"]                     = "String";
	Items["Document"]                    = "String";
	Items["DocumentNumerator"]           = "String";
	Items["Sequence"]                    = "String";
	Items["DocumentJournal"]             = "String";
	Items["Enum"]                        = "String";
	Items["Report"]                      = "String";
	Items["DataProcessor"]               = "String";
	Items["InformationRegister"]         = "String";
	Items["AccumulationRegister"]        = "String";
	Items["ChartOfCharacteristicTypes"]  = "String";
	Items["ChartOfAccounts"]             = "String";
	Items["AccountingRegister"]          = "String";
	Items["ChartOfCalculationTypes"]     = "String";
	Items["CalculationRegister"]         = "String";
	Items["BusinessProcess"]             = "String";
	Items["Task"]                        = "String";
	Items["ExternalDataSource"]          = "String";
	Return This;
EndFunction // ConfigurationChildObjects()

#EndRegion // Configuration

#Region Language

Function Language()
	This = Record(MDObjectBase());
	This["Properties"] = LanguageProperties();
	Return This;
EndFunction // Foo()

Function LanguageProperties()
	This = Record();
	This["Name"]          = "String";
	This["Synonym"]       = "LocalStringType";
	This["Comment"]       = "String";
	This["LanguageCode"]  = "String";
	Return This;
EndFunction // LanguageProperties()

#EndRegion // Language

#Region AccountingRegister

Function AccountingRegister()
	This = Record(MDObjectBase());
	This["Properties"] = AccountingRegisterProperties();
	This["ChildObjects"] = AccountingRegisterChildObjects();
	Return This;
EndFunction // AccountingRegister()

Function AccountingRegisterProperties()
	This = Record();
	This["Name"]                      = "String";
	This["Synonym"]                   = "LocalStringType";
	This["Comment"]                   = "String";
	This["UseStandardCommands"]       = Enums.Boolean;
	This["IncludeHelpInContents"]     = Enums.Boolean;
	This["ChartOfAccounts"]           = "MDObjectRef";
	This["Correspondence"]            = Enums.Boolean;
	This["PeriodAdjustmentLength"]    = "Decimal";
	This["DefaultListForm"]           = "MDObjectRef";
	This["AuxiliaryListForm"]         = "MDObjectRef";
	This["StandardAttributes"]        = "StandardAttributes";
	This["DataLockControlMode"]       = Enums.DefaultDataLockControlMode;
	This["EnableTotalsSplitting"]     = Enums.Boolean;
	This["FullTextSearch"]            = Enums.FullTextSearchUsing;
	This["ListPresentation"]          = "LocalStringType";
	This["ExtendedListPresentation"]  = "LocalStringType";
	This["Explanation"]               = "LocalStringType";
	Return This;
EndFunction // AccountingRegisterProperties()

Function AccountingRegisterChildObjects()
	This = Object();
	Items = This.Items;
	Items["Dimension"]  = "Dimension";
	Items["Resource"]   = "Resource";
	Items["Attribute"]  = "Attribute";
	Items["Form"]       = "String";
	Items["Template"]   = "String";
	Items["Command"]    = "Command";
	Return This;
EndFunction // AccountingRegisterChildObjects()

#EndRegion // AccountingRegister

#Region AccumulationRegister

Function AccumulationRegister()
	This = Record(MDObjectBase());
	This["Properties"] = AccumulationRegisterProperties();
	This["ChildObjects"] = AccumulationRegisterChildObjects();
	Return This;
EndFunction // AccumulationRegister()

Function AccumulationRegisterProperties()
	This = Record();
	This["Name"]                      = "String";
	This["Synonym"]                   = "LocalStringType";
	This["Comment"]                   = "String";
	This["UseStandardCommands"]       = Enums.Boolean;
	This["DefaultListForm"]           = "MDObjectRef";
	This["AuxiliaryListForm"]         = "MDObjectRef";
	This["RegisterType"]              = Enums.AccumulationRegisterType;
	This["IncludeHelpInContents"]     = Enums.Boolean;
	This["StandardAttributes"]        = "StandardAttributes";
	This["DataLockControlMode"]       = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]            = Enums.FullTextSearchUsing;
	This["EnableTotalsSplitting"]     = Enums.Boolean;
	This["ListPresentation"]          = "LocalStringType";
	This["ExtendedListPresentation"]  = "LocalStringType";
	This["Explanation"]               = "LocalStringType";
	Return This;
EndFunction // AccumulationRegisterProperties()

Function AccumulationRegisterChildObjects()
	This = Object();
	Items = This.Items;
	Items["Resource"]   = "Resource";
	Items["Attribute"]  = "Attribute";
	Items["Dimension"]  = "Dimension";
	Items["Form"]       = "String";
	Items["Template"]   = "String";
	Items["Command"]    = "Command";
	Return This;
EndFunction // AccumulationRegisterChildObjects()

#EndRegion // AccumulationRegister

#Region BusinessProcess

Function BusinessProcess()
	This = Record(MDObjectBase());
	This["Properties"] = BusinessProcessProperties();
	This["ChildObjects"] = BusinessProcessChildObjects();
	Return This;
EndFunction // BusinessProcess()

Function BusinessProcessProperties()
	This = Record();
	This["Name"]                              = "String";
	This["Synonym"]                           = "LocalStringType";
	This["Comment"]                           = "String";
	This["UseStandardCommands"]               = Enums.Boolean;
	This["EditType"]                          = Enums.EditType;
	This["InputByString"]                     = "FieldList";
	This["CreateOnInput"]                     = Enums.CreateOnInput;
	This["SearchStringModeOnInputByString"]   = Enums.SearchStringModeOnInputByString;
	This["ChoiceDataGetModeOnInputByString"]  = Enums.ChoiceDataGetModeOnInputByString;
	This["FullTextSearchOnInputByString"]     = Enums.FullTextSearchOnInputByString;
	This["DefaultObjectForm"]                 = "MDObjectRef";
	This["DefaultListForm"]                   = "MDObjectRef";
	This["DefaultChoiceForm"]                 = "MDObjectRef";
	This["AuxiliaryObjectForm"]               = "MDObjectRef";
	This["AuxiliaryListForm"]                 = "MDObjectRef";
	This["AuxiliaryChoiceForm"]               = "MDObjectRef";
	This["ChoiceHistoryOnInput"]              = Enums.ChoiceHistoryOnInput;
	This["NumberType"]                        = Enums.BusinessProcessNumberType;
	This["NumberLength"]                      = "Decimal";
	This["NumberAllowedLength"]               = Enums.AllowedLength;
	This["CheckUnique"]                       = Enums.Boolean;
	This["StandardAttributes"]                = "StandardAttributes";
	This["Characteristics"]                   = "Characteristics";
	This["Autonumbering"]                     = Enums.Boolean;
	This["BasedOn"]                           = "MDListType";
	This["NumberPeriodicity"]                 = Enums.BusinessProcessNumberPeriodicity;
	This["Task"]                              = "MDObjectRef";
	This["CreateTaskInPrivilegedMode"]        = Enums.Boolean;
	This["DataLockFields"]                    = "FieldList";
	This["DataLockControlMode"]               = Enums.DefaultDataLockControlMode;
	This["IncludeHelpInContents"]             = Enums.Boolean;
	This["FullTextSearch"]                    = Enums.FullTextSearchUsing;
	This["ObjectPresentation"]                = "LocalStringType";
	This["ExtendedObjectPresentation"]        = "LocalStringType";
	This["ListPresentation"]                  = "LocalStringType";
	This["ExtendedListPresentation"]          = "LocalStringType";
	This["Explanation"]                       = "LocalStringType";
	Return This;
EndFunction // BusinessProcessProperties()

Function BusinessProcessChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"]       = "Attribute";
	Items["TabularSection"]  = "TabularSection";
	Items["Form"]            = "String";
	Items["Template"]        = "String";
	Items["Command"]         = "Command";
	Return This;
EndFunction // BusinessProcessChildObjects()

#EndRegion // BusinessProcess

#Region CalculationRegister

Function CalculationRegister()
	This = Record(MDObjectBase());
	This["Properties"] = CalculationRegisterProperties();
	This["ChildObjects"] = CalculationRegisterChildObjects();
	Return This;
EndFunction // CalculationRegister()

Function CalculationRegisterProperties()
	This = Record();
	This["Name"]                      = "String";
	This["Synonym"]                   = "LocalStringType";
	This["Comment"]                   = "String";
	This["UseStandardCommands"]       = Enums.Boolean;
	This["DefaultListForm"]           = "MDObjectRef";
	This["AuxiliaryListForm"]         = "MDObjectRef";
	This["Periodicity"]               = Enums.CalculationRegisterPeriodicity;
	This["ActionPeriod"]              = Enums.Boolean;
	This["BasePeriod"]                = Enums.Boolean;
	This["Schedule"]                  = "MDObjectRef";
	This["ScheduleValue"]             = "MDObjectRef";
	This["ScheduleDate"]              = "MDObjectRef";
	This["ChartOfCalculationTypes"]   = "MDObjectRef";
	This["IncludeHelpInContents"]     = Enums.Boolean;
	This["StandardAttributes"]        = "StandardAttributes";
	This["DataLockControlMode"]       = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]            = Enums.FullTextSearchUsing;
	This["ListPresentation"]          = "LocalStringType";
	This["ExtendedListPresentation"]  = "LocalStringType";
	This["Explanation"]               = "LocalStringType";
	Return This;
EndFunction // CalculationRegisterProperties()

Function CalculationRegisterChildObjects()
	This = Object();
	Items = This.Items;
	Items["Resource"]       = "Resource";
	Items["Attribute"]      = "Attribute";
	Items["Dimension"]      = "Dimension";
	Items["Recalculation"]  = "String";
	Items["Form"]           = "String";
	Items["Template"]       = "String";
	Items["Command"]        = "Command";
	Return This;
EndFunction // CalculationRegisterChildObjects()

#EndRegion // CalculationRegister

#Region Catalog

Function Catalog()
	This = Record(MDObjectBase());
	This["Properties"] = CatalogProperties();
	This["ChildObjects"] = CatalogChildObjects();
	Return This;
EndFunction // Catalog()

Function CatalogProperties()
	This = Record();
	This["Name"]                              = "String";
	This["Synonym"]                           = "LocalStringType";
	This["Comment"]                           = "String";
	This["Hierarchical"]                      = Enums.Boolean;
	This["HierarchyType"]                     = Enums.HierarchyType;
	This["LimitLevelCount"]                   = Enums.Boolean;
	This["LevelCount"]                        = "Decimal";
	This["FoldersOnTop"]                      = Enums.Boolean;
	This["UseStandardCommands"]               = Enums.Boolean;
	This["Owners"]                            = "MDListType";
	This["SubordinationUse"]                  = Enums.SubordinationUse;
	This["CodeLength"]                        = "Decimal";
	This["DescriptionLength"]                 = "Decimal";
	This["CodeType"]                          = Enums.CatalogCodeType;
	This["CodeAllowedLength"]                 = Enums.AllowedLength;
	This["CodeSeries"]                        = Enums.CatalogCodesSeries;
	This["CheckUnique"]                       = Enums.Boolean;
	This["Autonumbering"]                     = Enums.Boolean;
	This["DefaultPresentation"]               = Enums.CatalogMainPresentation;
	This["StandardAttributes"]                = "StandardAttributes";
	This["Characteristics"]                   = "Characteristics";
	This["PredefinedDataUpdate"]              = Enums.PredefinedDataUpdate;
	This["EditType"]                          = Enums.EditType;
	This["QuickChoice"]                       = Enums.Boolean;
	This["ChoiceMode"]                        = Enums.ChoiceMode;
	This["InputByString"]                     = "FieldList";
	This["SearchStringModeOnInputByString"]   = Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"]     = Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"]  = Enums.ChoiceDataGetModeOnInputByString;
	This["DefaultObjectForm"]                 = "MDObjectRef";
	This["DefaultFolderForm"]                 = "MDObjectRef";
	This["DefaultListForm"]                   = "MDObjectRef";
	This["DefaultChoiceForm"]                 = "MDObjectRef";
	This["DefaultFolderChoiceForm"]           = "MDObjectRef";
	This["AuxiliaryObjectForm"]               = "MDObjectRef";
	This["AuxiliaryFolderForm"]               = "MDObjectRef";
	This["AuxiliaryListForm"]                 = "MDObjectRef";
	This["AuxiliaryChoiceForm"]               = "MDObjectRef";
	This["AuxiliaryFolderChoiceForm"]         = "MDObjectRef";
	This["IncludeHelpInContents"]             = Enums.Boolean;
	This["BasedOn"]                           = "MDListType";
	This["DataLockFields"]                    = "FieldList";
	This["DataLockControlMode"]               = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]                    = Enums.FullTextSearchUsing;
	This["ObjectPresentation"]                = "LocalStringType";
	This["ExtendedObjectPresentation"]        = "LocalStringType";
	This["ListPresentation"]                  = "LocalStringType";
	This["ExtendedListPresentation"]          = "LocalStringType";
	This["Explanation"]                       = "LocalStringType";
	This["CreateOnInput"]                     = Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"]              = Enums.ChoiceHistoryOnInput;
	This["DataHistory"]                       = Enums.DataHistoryUse;
	Return This;
EndFunction // CatalogProperties()

Function CatalogChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Return This;
EndFunction // CatalogChildObjects()

#EndRegion // Catalog

#Region ChartOfAccounts

Function ChartOfAccounts()
	This = Record(MDObjectBase());
	This["Properties"] = ChartOfAccountsProperties();
	This["ChildObjects"] = ChartOfAccountsChildObjects();
	Return This;
EndFunction // ChartOfAccounts()

Function ChartOfAccountsProperties()
	This = Record();
	This["Name"]                              = "String";
	This["Synonym"]                           = "LocalStringType";
	This["Comment"]                           = "String";
	This["UseStandardCommands"]               = Enums.Boolean;
	This["IncludeHelpInContents"]             = Enums.Boolean;
	This["BasedOn"]                           = "MDListType";
	This["ExtDimensionTypes"]                 = "MDObjectRef";
	This["MaxExtDimensionCount"]              = "Decimal";
	This["CodeMask"]                          = "String";
	This["CodeLength"]                        = "Decimal";
	This["DescriptionLength"]                 = "Decimal";
	This["CodeSeries"]                        = Enums.CharOfAccountCodeSeries;
	This["CheckUnique"]                       = Enums.Boolean;
	This["DefaultPresentation"]               = Enums.AccountMainPresentation;
	This["StandardAttributes"]                = "StandardAttributes";
	This["Characteristics"]                   = "Characteristics";
	This["StandardTabularSections"]           = "StandardTabularSections";
	This["PredefinedDataUpdate"]              = Enums.PredefinedDataUpdate;
	This["EditType"]                          = Enums.EditType;
	This["QuickChoice"]                       = Enums.Boolean;
	This["ChoiceMode"]                        = Enums.ChoiceMode;
	This["InputByString"]                     = "FieldList";
	This["SearchStringModeOnInputByString"]   = Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"]     = Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"]  = Enums.ChoiceDataGetModeOnInputByString;
	This["CreateOnInput"]                     = Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"]              = Enums.ChoiceHistoryOnInput;
	This["DefaultObjectForm"]                 = "MDObjectRef";
	This["DefaultListForm"]                   = "MDObjectRef";
	This["DefaultChoiceForm"]                 = "MDObjectRef";
	This["AuxiliaryObjectForm"]               = "MDObjectRef";
	This["AuxiliaryListForm"]                 = "MDObjectRef";
	This["AuxiliaryChoiceForm"]               = "MDObjectRef";
	This["AutoOrderByCode"]                   = Enums.Boolean;
	This["OrderLength"]                       = "Decimal";
	This["DataLockFields"]                    = "FieldList";
	This["DataLockControlMode"]               = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]                    = Enums.FullTextSearchUsing;
	This["ObjectPresentation"]                = "LocalStringType";
	This["ExtendedObjectPresentation"]        = "LocalStringType";
	This["ListPresentation"]                  = "LocalStringType";
	This["ExtendedListPresentation"]          = "LocalStringType";
	This["Explanation"]                       = "LocalStringType";
	Return This;
EndFunction // ChartOfAccountsProperties()

Function ChartOfAccountsChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"]                   = "Attribute";
	Items["TabularSection"]              = "TabularSection";
	Items["AccountingFlag"]              = "AccountingFlag";
	Items["ExtDimensionAccountingFlag"]  = "ExtDimensionAccountingFlag";
	Items["Form"]                        = "String";
	Items["Template"]                    = "String";
	Items["Command"]                     = "Command";
	Return This;
EndFunction // ChartOfAccountsChildObjects()

#EndRegion // ChartOfAccounts

#Region ChartOfCalculationTypes

Function ChartOfCalculationTypes()
	This = Record(MDObjectBase());
	This["Properties"] = ChartOfCalculationTypesProperties();
	This["ChildObjects"] = ChartOfCalculationTypesChildObjects();
	Return This;
EndFunction // ChartOfCalculationTypes()

Function ChartOfCalculationTypesProperties()
	This = Record();
	This["Name"]                              = "String";
	This["Synonym"]                           = "LocalStringType";
	This["Comment"]                           = "String";
	This["UseStandardCommands"]               = Enums.Boolean;
	This["CodeLength"]                        = "Decimal";
	This["DescriptionLength"]                 = "Decimal";
	This["CodeType"]                          = Enums.ChartOfCalculationTypesCodeType;
	This["CodeAllowedLength"]                 = Enums.AllowedLength;
	This["DefaultPresentation"]               = Enums.CalculationTypeMainPresentation;
	This["EditType"]                          = Enums.EditType;
	This["QuickChoice"]                       = Enums.Boolean;
	This["ChoiceMode"]                        = Enums.ChoiceMode;
	This["InputByString"]                     = "FieldList";
	This["SearchStringModeOnInputByString"]   = Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"]     = Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"]  = Enums.ChoiceDataGetModeOnInputByString;
	This["CreateOnInput"]                     = Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"]              = Enums.ChoiceHistoryOnInput;
	This["DefaultObjectForm"]                 = "MDObjectRef";
	This["DefaultListForm"]                   = "MDObjectRef";
	This["DefaultChoiceForm"]                 = "MDObjectRef";
	This["AuxiliaryObjectForm"]               = "MDObjectRef";
	This["AuxiliaryListForm"]                 = "MDObjectRef";
	This["AuxiliaryChoiceForm"]               = "MDObjectRef";
	This["BasedOn"]                           = "MDListType";
	This["DependenceOnCalculationTypes"]      = Enums.ChartOfCalculationTypesBaseUse;
	This["BaseCalculationTypes"]              = "MDListType";
	This["ActionPeriodUse"]                   = Enums.Boolean;
	This["StandardAttributes"]                = "StandardAttributes";
	This["Characteristics"]                   = "Characteristics";
	This["StandardTabularSections"]           = "StandardTabularSections";
	This["PredefinedDataUpdate"]              = Enums.PredefinedDataUpdate;
	This["IncludeHelpInContents"]             = Enums.Boolean;
	This["DataLockFields"]                    = "FieldList";
	This["DataLockControlMode"]               = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]                    = Enums.FullTextSearchUsing;
	This["ObjectPresentation"]                = "LocalStringType";
	This["ExtendedObjectPresentation"]        = "LocalStringType";
	This["ListPresentation"]                  = "LocalStringType";
	This["ExtendedListPresentation"]          = "LocalStringType";
	This["Explanation"]                       = "LocalStringType";
	Return This;
EndFunction // ChartOfCalculationTypesProperties()

Function ChartOfCalculationTypesChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"]       = "Attribute";
	Items["TabularSection"]  = "TabularSection";
	Items["Form"]            = "String";
	Items["Template"]        = "String";
	Items["Command"]         = "Command";
	Return This;
EndFunction // ChartOfCalculationTypesChildObjects()

#EndRegion // ChartOfCalculationTypes

#Region ChartOfCharacteristicTypes

Function ChartOfCharacteristicTypes()
	This = Record(MDObjectBase());
	This["Properties"] = ChartOfCharacteristicTypesProperties();
	This["ChildObjects"] = ChartOfCharacteristicTypesChildObjects();
	Return This;
EndFunction // ChartOfCharacteristicTypes()

Function ChartOfCharacteristicTypesProperties()
	This = Record();
	This["Name"]                              = "String";
	This["Synonym"]                           = "LocalStringType";
	This["Comment"]                           = "String";
	This["UseStandardCommands"]               = Enums.Boolean;
	This["IncludeHelpInContents"]             = Enums.Boolean;
	This["CharacteristicExtValues"]           = "MDObjectRef";
	//This["Type"]                              = "TypeDescription";
	This["Hierarchical"]                      = Enums.Boolean;
	This["FoldersOnTop"]                      = Enums.Boolean;
	This["CodeLength"]                        = "Decimal";
	This["CodeAllowedLength"]                 = Enums.AllowedLength;
	This["DescriptionLength"]                 = "Decimal";
	This["CodeSeries"]                        = Enums.CharacteristicKindCodesSeries;
	This["CheckUnique"]                       = Enums.Boolean;
	This["Autonumbering"]                     = Enums.Boolean;
	This["DefaultPresentation"]               = Enums.CharacteristicTypeMainPresentation;
	This["StandardAttributes"]                = "StandardAttributes";
	This["Characteristics"]                   = "Characteristics";
	This["PredefinedDataUpdate"]              = Enums.PredefinedDataUpdate;
	This["EditType"]                          = Enums.EditType;
	This["QuickChoice"]                       = Enums.Boolean;
	This["ChoiceMode"]                        = Enums.ChoiceMode;
	This["InputByString"]                     = "FieldList";
	This["CreateOnInput"]                     = Enums.CreateOnInput;
	This["SearchStringModeOnInputByString"]   = Enums.SearchStringModeOnInputByString;
	This["ChoiceDataGetModeOnInputByString"]  = Enums.ChoiceDataGetModeOnInputByString;
	This["FullTextSearchOnInputByString"]     = Enums.FullTextSearchOnInputByString;
	This["ChoiceHistoryOnInput"]              = Enums.ChoiceHistoryOnInput;
	This["DefaultObjectForm"]                 = "MDObjectRef";
	This["DefaultFolderForm"]                 = "MDObjectRef";
	This["DefaultListForm"]                   = "MDObjectRef";
	This["DefaultChoiceForm"]                 = "MDObjectRef";
	This["DefaultFolderChoiceForm"]           = "MDObjectRef";
	This["AuxiliaryObjectForm"]               = "MDObjectRef";
	This["AuxiliaryFolderForm"]               = "MDObjectRef";
	This["AuxiliaryListForm"]                 = "MDObjectRef";
	This["AuxiliaryChoiceForm"]               = "MDObjectRef";
	This["AuxiliaryFolderChoiceForm"]         = "MDObjectRef";
	This["BasedOn"]                           = "MDListType";
	This["DataLockFields"]                    = "FieldList";
	This["DataLockControlMode"]               = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]                    = Enums.FullTextSearchUsing;
	This["ObjectPresentation"]                = "LocalStringType";
	This["ExtendedObjectPresentation"]        = "LocalStringType";
	This["ListPresentation"]                  = "LocalStringType";
	This["ExtendedListPresentation"]          = "LocalStringType";
	This["Explanation"]                       = "LocalStringType";
	Return This;
EndFunction // ChartOfCharacteristicTypesProperties()

Function ChartOfCharacteristicTypesChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"]       = "Attribute";
	Items["TabularSection"]  = "TabularSection";
	Items["Form"]            = "String";
	Items["Template"]        = "String";
	Items["Command"]         = "Command";
	Return This;
EndFunction // ChartOfCharacteristicTypesChildObjects()

#EndRegion // ChartOfCharacteristicTypes

#Region CommandGroup

Function CommandGroup()
	This = Record(MDObjectBase());
	This["Properties"] = CommandGroupProperties();
	This["ChildObjects"] = CommandGroupChildObjects();
	Return This;
EndFunction // CommandGroup()

Function CommandGroupProperties()
	This = Record();
	This["Name"]            = "String";
	This["Synonym"]         = "LocalStringType";
	This["Comment"]         = "String";
	This["Representation"]  = Enums.ButtonRepresentation;
	This["ToolTip"]         = "LocalStringType";
	//This["Picture"]         = ;
	This["Category"]        = Enums.CommandGroupCategory;
	Return This;
EndFunction // CommandGroupProperties()

Function CommandGroupChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // CommandGroupChildObjects()

#EndRegion // CommandGroup

#Region CommonAttribute

Function CommonAttribute()
	This = Record(MDObjectBase());
	This["Properties"] = CommonAttributeProperties();
	This["ChildObjects"] = CommonAttributeChildObjects();
	Return This;
EndFunction // CommonAttribute()

Function CommonAttributeProperties()
	This = Record();
	This["Name"]                               = "String";
	This["Synonym"]                            = "LocalStringType";
	This["Comment"]                            = "String";
	//This["Type"]                               = "TypeDescription";
	This["PasswordMode"]                       = Enums.Boolean;
	This["Format"]                             = "LocalStringType";
	This["EditFormat"]                         = "LocalStringType";
	This["ToolTip"]                            = "LocalStringType";
	This["MarkNegatives"]                      = Enums.Boolean;
	This["Mask"]                               = "String";
	This["MultiLine"]                          = Enums.Boolean;
	This["ExtendedEdit"]                       = Enums.Boolean;
	//This["MinValue"]                           = ;
	//This["MaxValue"]                           = ;
	This["FillFromFillingValue"]               = Enums.Boolean;
	//This["FillValue"]                          = ;
	This["FillChecking"]                       = Enums.FillChecking;
	This["ChoiceFoldersAndItems"]              = Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"]               = "ChoiceParameterLinks";
	//This["ChoiceParameters"]                   = ;
	This["QuickChoice"]                        = Enums.UseQuickChoice;
	This["CreateOnInput"]                      = Enums.CreateOnInput;
	This["ChoiceForm"]                         = "MDObjectRef";
	This["LinkByType"]                         = "TypeLink";
	This["ChoiceHistoryOnInput"]               = Enums.ChoiceHistoryOnInput;
	//This["Content"]                            = CommonAttributeContent();
	This["AutoUse"]                            = Enums.CommonAttributeAutoUse;
	This["DataSeparation"]                     = Enums.CommonAttributeDataSeparation;
	This["SeparatedDataUse"]                   = Enums.CommonAttributeSeparatedDataUse;
	This["DataSeparationValue"]                = "MDObjectRef";
	This["DataSeparationUse"]                  = "MDObjectRef";
	This["ConditionalSeparation"]              = "MDObjectRef";
	This["UsersSeparation"]                    = Enums.CommonAttributeUsersSeparation;
	This["AuthenticationSeparation"]           = Enums.CommonAttributeAuthenticationSeparation;
	This["ConfigurationExtensionsSeparation"]  = Enums.CommonAttributeConfigurationExtensionsSeparation;
	This["Indexing"]                           = Enums.Indexing;
	This["FullTextSearch"]                     = Enums.FullTextSearchUsing;
	This["DataHistory"]                        = Enums.DataHistoryUse;
	Return This;
EndFunction // CommonAttributeProperties()

Function CommonAttributeChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // CommonAttributeChildObjects()

#EndRegion // CommonAttribute

#Region CommonCommand

Function CommonCommand()
	This = Record(MDObjectBase());
	This["Properties"] = CommonCommandProperties();
	This["ChildObjects"] = CommonCommandChildObjects();
	Return This;
EndFunction // CommonCommand()

Function CommonCommandProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	//This["Group"]                  = IncludeInCommandCategoriesType;
	This["Representation"]         = Enums.ButtonRepresentation;
	This["ToolTip"]                = "LocalStringType";
	//This["Picture"]                = ;
	//This["Shortcut"]               = ;
	This["IncludeHelpInContents"]  = Enums.Boolean;
	//This["CommandParameterType"]   = "TypeDescription";
	This["ParameterUseMode"]       = Enums.CommandParameterUseMode;
	This["ModifiesData"]           = Enums.Boolean;
	Return This;
EndFunction // CommonCommandProperties()

Function CommonCommandChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // CommonCommandChildObjects()

#EndRegion // CommonCommand

#Region CommonForm

Function CommonForm()
	This = Record(MDObjectBase());
	This["Properties"] = CommonFormProperties();
	This["ChildObjects"] = CommonFormChildObjects();
	Return This;
EndFunction // CommonForm()

Function CommonFormProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	This["FormType"]               = Enums.FormType;
	This["IncludeHelpInContents"]  = Enums.Boolean;
	//This["UsePurposes"]            = "FixedArray";
	This["UseStandardCommands"]    = Enums.Boolean;
	This["ExtendedPresentation"]   = "LocalStringType";
	This["Explanation"]            = "LocalStringType";
	Return This;
EndFunction // CommonFormProperties()

Function CommonFormChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // CommonFormChildObjects()

#EndRegion // CommonForm

#Region CommonModule

Function CommonModule()
	This = Record(MDObjectBase());
	This["Properties"] = CommonModuleProperties();
	This["ChildObjects"] = CommonModuleChildObjects();
	Return This;
EndFunction // CommonModule()

Function CommonModuleProperties()
	This = Record();
	This["Name"]                       = "String";
	This["Synonym"]                    = "LocalStringType";
	This["Comment"]                    = "String";
	This["Global"]                     = Enums.Boolean;
	This["ClientManagedApplication"]   = Enums.Boolean;
	This["Server"]                     = Enums.Boolean;
	This["ExternalConnection"]         = Enums.Boolean;
	This["ClientOrdinaryApplication"]  = Enums.Boolean;
	This["Client"]                     = Enums.Boolean;
	This["ServerCall"]                 = Enums.Boolean;
	This["Privileged"]                 = Enums.Boolean;
	This["ReturnValuesReuse"]          = Enums.ReturnValuesReuse;
	Return This;
EndFunction // CommonModuleProperties()

Function CommonModuleChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // CommonModuleChildObjects()

#EndRegion // CommonModule

#Region CommonPicture

Function CommonPicture()
	This = Record(MDObjectBase());
	This["Properties"] = CommonPictureProperties();
	This["ChildObjects"] = CommonPictureChildObjects();
	Return This;
EndFunction // CommonPicture()

Function CommonPictureProperties()
	This = Record();
	This["Name"]     = "String";
	This["Synonym"]  = "LocalStringType";
	This["Comment"]  = "String";
	Return This;
EndFunction // CommonPictureProperties()

Function CommonPictureChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // CommonPictureChildObjects()

#EndRegion // CommonPicture

#Region CommonTemplate

Function CommonTemplate()
	This = Record(MDObjectBase());
	This["Properties"] = CommonTemplateProperties();
	This["ChildObjects"] = CommonTemplateChildObjects();
	Return This;
EndFunction // CommonTemplate()

Function CommonTemplateProperties()
	This = Record();
	This["Name"]          = "String";
	This["Synonym"]       = "LocalStringType";
	This["Comment"]       = "String";
	This["TemplateType"]  = Enums.TemplateType;
	Return This;
EndFunction // CommonTemplateProperties()

Function CommonTemplateChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // CommonTemplateChildObjects()

#EndRegion // CommonTemplate

#Region Constant

Function Constant()
	This = Record(MDObjectBase());
	This["Properties"] = ConstantProperties();
	This["ChildObjects"] = ConstantChildObjects();
	Return This;
EndFunction // Constant()

Function ConstantProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	//This["Type"]                   = "TypeDescription";
	This["UseStandardCommands"]    = Enums.Boolean;
	This["DefaultForm"]            = "MDObjectRef";
	This["ExtendedPresentation"]   = "LocalStringType";
	This["Explanation"]            = "LocalStringType";
	This["PasswordMode"]           = Enums.Boolean;
	This["Format"]                 = "LocalStringType";
	This["EditFormat"]             = "LocalStringType";
	This["ToolTip"]                = "LocalStringType";
	This["MarkNegatives"]          = Enums.Boolean;
	This["Mask"]                   = "String";
	This["MultiLine"]              = Enums.Boolean;
	This["ExtendedEdit"]           = Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillChecking"]           = Enums.FillChecking;
	This["ChoiceFoldersAndItems"]  = Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"]   = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"]            = Enums.UseQuickChoice;
	This["ChoiceForm"]             = "MDObjectRef";
	This["LinkByType"]             = "TypeLink";
	This["ChoiceHistoryOnInput"]   = Enums.ChoiceHistoryOnInput;
	This["DataLockControlMode"]    = Enums.DefaultDataLockControlMode;
	Return This;
EndFunction // ConstantProperties()

Function ConstantChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // ConstantChildObjects()

#EndRegion // Constant

#Region DataProcessor

Function DataProcessor()
	This = Record(MDObjectBase());
	This["Properties"] = DataProcessorProperties();
	This["ChildObjects"] = DataProcessorChildObjects();
	Return This;
EndFunction // DataProcessor()

Function DataProcessorProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	This["UseStandardCommands"]    = Enums.Boolean;
	This["DefaultForm"]            = "MDObjectRef";
	This["AuxiliaryForm"]          = "MDObjectRef";
	This["IncludeHelpInContents"]  = Enums.Boolean;
	This["ExtendedPresentation"]   = "LocalStringType";
	This["Explanation"]            = "LocalStringType";
	Return This;
EndFunction // DataProcessorProperties()

Function DataProcessorChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"]       = "Attribute";
	Items["TabularSection"]  = "TabularSection";
	Items["Form"]            = "String";
	Items["Template"]        = "String";
	Items["Command"]         = "Command";
	Return This;
EndFunction // DataProcessorChildObjects()

#EndRegion // DataProcessor

#Region DocumentJournal

Function DocumentJournal()
	This = Record(MDObjectBase());
	This["Properties"] = DocumentJournalProperties();
	This["ChildObjects"] = DocumentJournalChildObjects();
	Return This;
EndFunction // DocumentJournal()

Function DocumentJournalProperties()
	This = Record();
	This["Name"]                      = "String";
	This["Synonym"]                   = "LocalStringType";
	This["Comment"]                   = "String";
	This["DefaultForm"]               = "MDObjectRef";
	This["AuxiliaryForm"]             = "MDObjectRef";
	This["UseStandardCommands"]       = Enums.Boolean;
	This["RegisteredDocuments"]       = "MDListType";
	This["IncludeHelpInContents"]     = Enums.Boolean;
	This["StandardAttributes"]        = "StandardAttributes";
	This["ListPresentation"]          = "LocalStringType";
	This["ExtendedListPresentation"]  = "LocalStringType";
	This["Explanation"]               = "LocalStringType";
	Return This;
EndFunction // DocumentJournalProperties()

Function DocumentJournalChildObjects()
	This = Object();
	Items = This.Items;
	Items["Column"]    = Column();
	Items["Form"]      = "String";
	Items["Template"]  = "String";
	Items["Command"]   = "Command";
	Return This;
EndFunction // DocumentJournalChildObjects()

#EndRegion // DocumentJournal

#Region DocumentNumerator

Function DocumentNumerator()
	This = Record(MDObjectBase());
	This["Properties"] = DocumentNumeratorProperties();
	This["ChildObjects"] = DocumentNumeratorChildObjects();
	Return This;
EndFunction // DocumentNumerator()

Function DocumentNumeratorProperties()
	This = Record();
	This["Name"]                 = "String";
	This["Synonym"]              = "LocalStringType";
	This["Comment"]              = "String";
	This["NumberType"]           = Enums.DocumentNumberType;
	This["NumberLength"]         = "Decimal";
	This["NumberAllowedLength"]  = Enums.AllowedLength;
	This["NumberPeriodicity"]    = Enums.DocumentNumberPeriodicity;
	This["CheckUnique"]          = Enums.Boolean;
	Return This;
EndFunction // DocumentNumeratorProperties()

Function DocumentNumeratorChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // DocumentNumeratorChildObjects()

#EndRegion // DocumentNumerator

#Region Document

Function Document()
	This = Record(MDObjectBase());
	This["Properties"] = DocumentProperties();
	This["ChildObjects"] = DocumentChildObjects();
	Return This;
EndFunction // Document()

Function DocumentProperties()
	This = Record();
	This["Name"]                              = "String";
	This["Synonym"]                           = "LocalStringType";
	This["Comment"]                           = "String";
	This["UseStandardCommands"]               = Enums.Boolean;
	This["Numerator"]                         = "MDObjectRef";
	This["NumberType"]                        = Enums.DocumentNumberType;
	This["NumberLength"]                      = "Decimal";
	This["NumberAllowedLength"]               = Enums.AllowedLength;
	This["NumberPeriodicity"]                 = Enums.DocumentNumberPeriodicity;
	This["CheckUnique"]                       = Enums.Boolean;
	This["Autonumbering"]                     = Enums.Boolean;
	This["StandardAttributes"]                = "StandardAttributes";
	This["Characteristics"]                   = "Characteristics";
	This["BasedOn"]                           = "MDListType";
	This["InputByString"]                     = "FieldList";
	This["CreateOnInput"]                     = Enums.CreateOnInput;
	This["SearchStringModeOnInputByString"]   = Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"]     = Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"]  = Enums.ChoiceDataGetModeOnInputByString;
	This["DefaultObjectForm"]                 = "MDObjectRef";
	This["DefaultListForm"]                   = "MDObjectRef";
	This["DefaultChoiceForm"]                 = "MDObjectRef";
	This["AuxiliaryObjectForm"]               = "MDObjectRef";
	This["AuxiliaryListForm"]                 = "MDObjectRef";
	This["AuxiliaryChoiceForm"]               = "MDObjectRef";
	This["Posting"]                           = Enums.Posting;
	This["RealTimePosting"]                   = Enums.RealTimePosting;
	This["RegisterRecordsDeletion"]           = Enums.RegisterRecordsDeletion;
	This["RegisterRecordsWritingOnPost"]      = Enums.RegisterRecordsWritingOnPost;
	This["SequenceFilling"]                   = Enums.SequenceFilling;
	This["RegisterRecords"]                   = "MDListType";
	This["PostInPrivilegedMode"]              = Enums.Boolean;
	This["UnpostInPrivilegedMode"]            = Enums.Boolean;
	This["IncludeHelpInContents"]             = Enums.Boolean;
	This["DataLockFields"]                    = "FieldList";
	This["DataLockControlMode"]               = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]                    = Enums.FullTextSearchUsing;
	This["ObjectPresentation"]                = "LocalStringType";
	This["ExtendedObjectPresentation"]        = "LocalStringType";
	This["ListPresentation"]                  = "LocalStringType";
	This["ExtendedListPresentation"]          = "LocalStringType";
	This["Explanation"]                       = "LocalStringType";
	This["ChoiceHistoryOnInput"]              = Enums.ChoiceHistoryOnInput;
	This["DataHistory"]                       = Enums.DataHistoryUse;
	Return This;
EndFunction // DocumentProperties()

Function DocumentChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"]       = "Attribute";
	Items["Form"]            = "String";
	Items["TabularSection"]  = "TabularSection";
	Items["Template"]        = "String";
	Items["Command"]         = "Command";
	Return This;
EndFunction // DocumentChildObjects()

#EndRegion // Document

#Region Enum

Function Enum()
	This = Record(MDObjectBase());
	This["Properties"] = EnumProperties();
	This["ChildObjects"] = EnumChildObjects();
	Return This;
EndFunction // Enum()

Function EnumProperties()
	This = Record();
	This["Name"]                      = "String";
	This["Synonym"]                   = "LocalStringType";
	This["Comment"]                   = "String";
	This["UseStandardCommands"]       = Enums.Boolean;
	This["StandardAttributes"]        = "StandardAttributes";
	This["Characteristics"]           = "Characteristics";
	This["QuickChoice"]               = Enums.Boolean;
	This["ChoiceMode"]                = Enums.ChoiceMode;
	This["DefaultListForm"]           = "MDObjectRef";
	This["DefaultChoiceForm"]         = "MDObjectRef";
	This["AuxiliaryListForm"]         = "MDObjectRef";
	This["AuxiliaryChoiceForm"]       = "MDObjectRef";
	This["ListPresentation"]          = "LocalStringType";
	This["ExtendedListPresentation"]  = "LocalStringType";
	This["Explanation"]               = "LocalStringType";
	This["ChoiceHistoryOnInput"]      = Enums.ChoiceHistoryOnInput;
	Return This;
EndFunction // EnumProperties()

Function EnumChildObjects()
	This = Object();
	Items = This.Items;
	Items["EnumValue"]  = EnumValue();
	Items["Form"]       = "String";
	Items["Template"]   = "String";
	Items["Command"]    = "Command";
	Return This;
EndFunction // EnumChildObjects()

#EndRegion // Enum

#Region EventSubscription

Function EventSubscription()
	This = Record(MDObjectBase());
	This["Properties"] = EventSubscriptionProperties();
	This["ChildObjects"] = EventSubscriptionChildObjects();
	Return This;
EndFunction // EventSubscription()

Function EventSubscriptionProperties()
	This = Record();
	This["Name"]     = "String";
	This["Synonym"]  = "LocalStringType";
	This["Comment"]  = "String";
	//This["Source"]   = "TypeDescription";
	//This["Event"]    = "AliasedStringType";
	This["Handler"]  = "MDMethodRef";
	Return This;
EndFunction // EventSubscriptionProperties()

Function EventSubscriptionChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // EventSubscriptionChildObjects()

#EndRegion // EventSubscription

#Region ExchangePlan

Function ExchangePlan()
	This = Record(MDObjectBase());
	This["Properties"] = ExchangePlanProperties();
	This["ChildObjects"] = ExchangePlanChildObjects();
	Return This;
EndFunction // ExchangePlan()

Function ExchangePlanProperties()
	This = Record();
	This["Name"]                              = "String";
	This["Synonym"]                           = "LocalStringType";
	This["Comment"]                           = "String";
	This["UseStandardCommands"]               = Enums.Boolean;
	This["CodeLength"]                        = "Decimal";
	This["CodeAllowedLength"]                 = Enums.AllowedLength;
	This["DescriptionLength"]                 = "Decimal";
	This["DefaultPresentation"]               = Enums.DataExchangeMainPresentation;
	This["EditType"]                          = Enums.EditType;
	This["QuickChoice"]                       = Enums.Boolean;
	This["ChoiceMode"]                        = Enums.ChoiceMode;
	This["InputByString"]                     = "FieldList";
	This["SearchStringModeOnInputByString"]   = Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"]     = Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"]  = Enums.ChoiceDataGetModeOnInputByString;
	This["DefaultObjectForm"]                 = "MDObjectRef";
	This["DefaultListForm"]                   = "MDObjectRef";
	This["DefaultChoiceForm"]                 = "MDObjectRef";
	This["AuxiliaryObjectForm"]               = "MDObjectRef";
	This["AuxiliaryListForm"]                 = "MDObjectRef";
	This["AuxiliaryChoiceForm"]               = "MDObjectRef";
	This["StandardAttributes"]                = "StandardAttributes";
	This["Characteristics"]                   = "Characteristics";
	This["BasedOn"]                           = "MDListType";
	This["DistributedInfoBase"]               = Enums.Boolean;
	This["CreateOnInput"]                     = Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"]              = Enums.ChoiceHistoryOnInput;
	This["IncludeHelpInContents"]             = Enums.Boolean;
	This["DataLockFields"]                    = "FieldList";
	This["DataLockControlMode"]               = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]                    = Enums.FullTextSearchUsing;
	This["ObjectPresentation"]                = "LocalStringType";
	This["ExtendedObjectPresentation"]        = "LocalStringType";
	This["ListPresentation"]                  = "LocalStringType";
	This["ExtendedListPresentation"]          = "LocalStringType";
	This["Explanation"]                       = "LocalStringType";
	Return This;
EndFunction // ExchangePlanProperties()

Function ExchangePlanChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"]       = "Attribute";
	Items["TabularSection"]  = "TabularSection";
	Items["Form"]            = "String";
	Items["Template"]        = "String";
	Items["Command"]         = "Command";
	Return This;
EndFunction // ExchangePlanChildObjects()

#EndRegion // ExchangePlan

#Region FilterCriterion

Function FilterCriterion()
	This = Record(MDObjectBase());
	This["Properties"] = FilterCriterionProperties();
	This["ChildObjects"] = FilterCriterionChildObjects();
	Return This;
EndFunction // FilterCriterion()

Function FilterCriterionProperties()
	This = Record();
	This["Name"]                      = "String";
	This["Synonym"]                   = "LocalStringType";
	This["Comment"]                   = "String";
	//This["Type"]                      = "TypeDescription";
	This["UseStandardCommands"]       = Enums.Boolean;
	This["Content"]                   = "MDListType";
	This["DefaultForm"]               = "MDObjectRef";
	This["AuxiliaryForm"]             = "MDObjectRef";
	This["ListPresentation"]          = "LocalStringType";
	This["ExtendedListPresentation"]  = "LocalStringType";
	This["Explanation"]               = "LocalStringType";
	Return This;
EndFunction // FilterCriterionProperties()

Function FilterCriterionChildObjects()
	This = Object();
	Items = This.Items;
	Items["Form"]     = "String";
	Items["Command"]  = "Command";
	Return This;
EndFunction // FilterCriterionChildObjects()

#EndRegion // FilterCriterion

#Region FunctionalOption

Function FunctionalOption()
	This = Record(MDObjectBase());
	This["Properties"] = FunctionalOptionProperties();
	This["ChildObjects"] = FunctionalOptionChildObjects();
	Return This;
EndFunction // FunctionalOption()

Function FunctionalOptionProperties()
	This = Record();
	This["Name"]               = "String";
	This["Synonym"]            = "LocalStringType";
	This["Comment"]            = "String";
	This["Location"]           = "MDObjectRef";
	This["PrivilegedGetMode"]  = Enums.Boolean;
	//This["Content"]            = FuncOptionContentType();
	Return This;
EndFunction // FunctionalOptionProperties()

Function FunctionalOptionChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // FunctionalOptionChildObjects()

#EndRegion // FunctionalOption

#Region FunctionalOptionsParameter

Function FunctionalOptionsParameter()
	This = Record(MDObjectBase());
	This["Properties"] = FunctionalOptionsParameterProperties();
	This["ChildObjects"] = FunctionalOptionsParameterChildObjects();
	Return This;
EndFunction // FunctionalOptionsParameter()

Function FunctionalOptionsParameterProperties()
	This = Record();
	This["Name"]     = "String";
	This["Synonym"]  = "LocalStringType";
	This["Comment"]  = "String";
	This["Use"]      = "MDListType";
	Return This;
EndFunction // FunctionalOptionsParameterProperties()

Function FunctionalOptionsParameterChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // FunctionalOptionsParameterChildObjects()

#EndRegion // FunctionalOptionsParameter

#Region HTTPService

Function HTTPService()
	This = Record(MDObjectBase());
	This["Properties"] = HTTPServiceProperties();
	This["ChildObjects"] = HTTPServiceChildObjects();
	Return This;
EndFunction // HTTPService()

Function HTTPServiceProperties()
	This = Record();
	This["Name"]           = "String";
	This["Synonym"]        = "LocalStringType";
	This["Comment"]        = "String";
	This["RootURL"]        = "String";
	This["ReuseSessions"]  = Enums.SessionReuseMode;
	This["SessionMaxAge"]  = "Decimal";
	Return This;
EndFunction // HTTPServiceProperties()

Function HTTPServiceChildObjects()
	This = Object();
	Items = This.Items;
	//Items["URLTemplate"] = ;
	Return This;
EndFunction // HTTPServiceChildObjects()

#EndRegion // HTTPService

#Region InformationRegister

Function InformationRegister()
	This = Record(MDObjectBase());
	This["Properties"] = InformationRegisterProperties();
	This["ChildObjects"] = InformationRegisterChildObjects();
	Return This;
EndFunction // InformationRegister()

Function InformationRegisterProperties()
	This = Record();
	This["Name"]                            = "String";
	This["Synonym"]                         = "LocalStringType";
	This["Comment"]                         = "String";
	This["UseStandardCommands"]             = Enums.Boolean;
	This["EditType"]                        = Enums.EditType;
	This["DefaultRecordForm"]               = "MDObjectRef";
	This["DefaultListForm"]                 = "MDObjectRef";
	This["AuxiliaryRecordForm"]             = "MDObjectRef";
	This["AuxiliaryListForm"]               = "MDObjectRef";
	This["StandardAttributes"]              = "StandardAttributes";
	This["InformationRegisterPeriodicity"]  = Enums.InformationRegisterPeriodicity;
	This["WriteMode"]                       = Enums.RegisterWriteMode;
	This["MainFilterOnPeriod"]              = Enums.Boolean;
	This["IncludeHelpInContents"]           = Enums.Boolean;
	This["DataLockControlMode"]             = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]                  = Enums.FullTextSearchUsing;
	This["EnableTotalsSliceFirst"]          = Enums.Boolean;
	This["EnableTotalsSliceLast"]           = Enums.Boolean;
	This["RecordPresentation"]              = "LocalStringType";
	This["ExtendedRecordPresentation"]      = "LocalStringType";
	This["ListPresentation"]                = "LocalStringType";
	This["ExtendedListPresentation"]        = "LocalStringType";
	This["Explanation"]                     = "LocalStringType";
	This["DataHistory"]                     = Enums.DataHistoryUse;
	Return This;
EndFunction // InformationRegisterProperties()

Function InformationRegisterChildObjects()
	This = Object();
	Items = This.Items;
	Items["Resource"]   = "Resource";
	Items["Attribute"]  = "Attribute";
	Items["Dimension"]  = "Dimension";
	Items["Form"]       = "String";
	Items["Template"]   = "String";
	Items["Command"]    = "Command";
	Return This;
EndFunction // InformationRegisterChildObjects()

#EndRegion // InformationRegister

#Region Report

Function Report()
	This = Record(MDObjectBase());
	This["Properties"] = ReportProperties();
	This["ChildObjects"] = ReportChildObjects();
	Return This;
EndFunction // Report()

Function ReportProperties()
	This = Record();
	This["Name"]                       = "String";
	This["Synonym"]                    = "LocalStringType";
	This["Comment"]                    = "String";
	This["UseStandardCommands"]        = Enums.Boolean;
	This["DefaultForm"]                = "MDObjectRef";
	This["AuxiliaryForm"]              = "MDObjectRef";
	This["MainDataCompositionSchema"]  = "MDObjectRef";
	This["DefaultSettingsForm"]        = "MDObjectRef";
	This["AuxiliarySettingsForm"]      = "MDObjectRef";
	This["DefaultVariantForm"]         = "MDObjectRef";
	This["VariantsStorage"]            = "MDObjectRef";
	This["SettingsStorage"]            = "MDObjectRef";
	This["IncludeHelpInContents"]      = Enums.Boolean;
	This["ExtendedPresentation"]       = "LocalStringType";
	This["Explanation"]                = "LocalStringType";
	Return This;
EndFunction // ReportProperties()

Function ReportChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"]       = "Attribute";
	Items["TabularSection"]  = "TabularSection";
	Items["Form"]            = "String";
	Items["Template"]        = "String";
	Items["Command"]         = "Command";
	Return This;
EndFunction // ReportChildObjects()

#EndRegion // Report

#Region Role

Function Role()
	This = Record(MDObjectBase());
	This["Properties"] = RoleProperties();
	This["ChildObjects"] = RoleChildObjects();
	Return This;
EndFunction // Role()

Function RoleProperties()
	This = Record();
	This["Name"]     = "String";
	This["Synonym"]  = "LocalStringType";
	This["Comment"]  = "String";
	Return This;
EndFunction // RoleProperties()

Function RoleChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // RoleChildObjects()

#EndRegion // Role

#Region ScheduledJob

Function ScheduledJob()
	This = Record(MDObjectBase());
	This["Properties"] = ScheduledJobProperties();
	This["ChildObjects"] = ScheduledJobChildObjects();
	Return This;
EndFunction // ScheduledJob()

Function ScheduledJobProperties()
	This = Record();
	This["Name"]                      = "String";
	This["Synonym"]                   = "LocalStringType";
	This["Comment"]                   = "String";
	This["MethodName"]                = "MDMethodRef";
	This["Description"]               = "String";
	This["Key"]                       = "String";
	This["Use"]                       = Enums.Boolean;
	This["Predefined"]                = Enums.Boolean;
	This["RestartCountOnFailure"]     = "Decimal";
	This["RestartIntervalOnFailure"]  = "Decimal";
	Return This;
EndFunction // ScheduledJobProperties()

Function ScheduledJobChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // ScheduledJobChildObjects()

#EndRegion // ScheduledJob

#Region Sequence

Function Sequence()
	This = Record(MDObjectBase());
	This["Properties"] = SequenceProperties();
	This["ChildObjects"] = SequenceChildObjects();
	Return This;
EndFunction // Sequence()

Function SequenceProperties()
	This = Record();
	This["Name"]                   = "String";
	This["Synonym"]                = "LocalStringType";
	This["Comment"]                = "String";
	This["MoveBoundaryOnPosting"]  = Enums.MoveBoundaryOnPosting;
	This["Documents"]              = "MDListType";
	This["RegisterRecords"]        = "MDListType";
	This["DataLockControlMode"]    = Enums.DefaultDataLockControlMode;
	Return This;
EndFunction // SequenceProperties()

Function SequenceChildObjects()
	This = Object();
	Items = This.Items;
	Items["Dimension"] = "Dimension";
	Return This;
EndFunction // SequenceChildObjects()

#EndRegion // Sequence

#Region SessionParameter

Function SessionParameter()
	This = Record(MDObjectBase());
	This["Properties"] = SessionParameterProperties();
	This["ChildObjects"] = SessionParameterChildObjects();
	Return This;
EndFunction // SessionParameter()

Function SessionParameterProperties()
	This = Record();
	This["Name"]     = "String";
	This["Synonym"]  = "LocalStringType";
	This["Comment"]  = "String";
	//This["Type"]     = "TypeDescription";
	Return This;
EndFunction // SessionParameterProperties()

Function SessionParameterChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // SessionParameterChildObjects()

#EndRegion // SessionParameter

#Region SettingsStorage

Function SettingsStorage()
	This = Record(MDObjectBase());
	This["Properties"] = SettingsStorageProperties();
	This["ChildObjects"] = SettingsStorageChildObjects();
	Return This;
EndFunction // SettingsStorage()

Function SettingsStorageProperties()
	This = Record();
	This["Name"]               = "String";
	This["Synonym"]            = "LocalStringType";
	This["Comment"]            = "String";
	This["DefaultSaveForm"]    = "MDObjectRef";
	This["DefaultLoadForm"]    = "MDObjectRef";
	This["AuxiliarySaveForm"]  = "MDObjectRef";
	This["AuxiliaryLoadForm"]  = "MDObjectRef";
	Return This;
EndFunction // SettingsStorageProperties()

Function SettingsStorageChildObjects()
	This = Object();
	Items = This.Items;
	Items["Form"]      = "String";
	Items["Template"]  = "String";
	Return This;
EndFunction // SettingsStorageChildObjects()

#EndRegion // SettingsStorage

#Region Subsystem

Function Subsystem()
	This = Record(MDObjectBase());
	This["Properties"] = SubsystemProperties();
	This["ChildObjects"] = SubsystemChildObjects();
	Return This;
EndFunction // Subsystem()

Function SubsystemProperties()
	This = Record();
	This["Name"]                       = "String";
	This["Synonym"]                    = "LocalStringType";
	This["Comment"]                    = "String";
	This["IncludeHelpInContents"]      = Enums.Boolean;
	This["IncludeInCommandInterface"]  = Enums.Boolean;
	This["Explanation"]                = "LocalStringType";
	//This["Picture"]                    = ;
	This["Content"]                    = "MDListType";
	Return This;
EndFunction // SubsystemProperties()

Function SubsystemChildObjects()
	This = Object();
	Items = This.Items;
	Items["Subsystem"] = "String";
	Return This;
EndFunction // SubsystemChildObjects()

#EndRegion // Subsystem

#Region Task

Function Task()
	This = Record(MDObjectBase());
	This["Properties"] = TaskProperties();
	This["ChildObjects"] = TaskChildObjects();
	Return This;
EndFunction // Task()

Function TaskProperties()
	This = Record();
	This["Name"]                              = "String";
	This["Synonym"]                           = "LocalStringType";
	This["Comment"]                           = "String";
	This["UseStandardCommands"]               = Enums.Boolean;
	This["NumberType"]                        = Enums.TaskNumberType;
	This["NumberLength"]                      = "Decimal";
	This["NumberAllowedLength"]               = Enums.AllowedLength;
	This["CheckUnique"]                       = Enums.Boolean;
	This["Autonumbering"]                     = Enums.Boolean;
	This["TaskNumberAutoPrefix"]              = Enums.TaskNumberAutoPrefix;
	This["DescriptionLength"]                 = "Decimal";
	This["Addressing"]                        = "MDObjectRef";
	This["MainAddressingAttribute"]           = "MDObjectRef";
	This["CurrentPerformer"]                  = "MDObjectRef";
	This["BasedOn"]                           = "MDListType";
	This["StandardAttributes"]                = "StandardAttributes";
	This["Characteristics"]                   = "Characteristics";
	This["DefaultPresentation"]               = Enums.TaskMainPresentation;
	This["EditType"]                          = Enums.EditType;
	This["InputByString"]                     = "FieldList";
	This["SearchStringModeOnInputByString"]   = Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"]     = Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"]  = Enums.ChoiceDataGetModeOnInputByString;
	This["CreateOnInput"]                     = Enums.CreateOnInput;
	This["DefaultObjectForm"]                 = "MDObjectRef";
	This["DefaultListForm"]                   = "MDObjectRef";
	This["DefaultChoiceForm"]                 = "MDObjectRef";
	This["AuxiliaryObjectForm"]               = "MDObjectRef";
	This["AuxiliaryListForm"]                 = "MDObjectRef";
	This["AuxiliaryChoiceForm"]               = "MDObjectRef";
	This["ChoiceHistoryOnInput"]              = Enums.ChoiceHistoryOnInput;
	This["IncludeHelpInContents"]             = Enums.Boolean;
	This["DataLockFields"]                    = "FieldList";
	This["DataLockControlMode"]               = Enums.DefaultDataLockControlMode;
	This["FullTextSearch"]                    = Enums.FullTextSearchUsing;
	This["ObjectPresentation"]                = "LocalStringType";
	This["ExtendedObjectPresentation"]        = "LocalStringType";
	This["ListPresentation"]                  = "LocalStringType";
	This["ExtendedListPresentation"]          = "LocalStringType";
	This["Explanation"]                       = "LocalStringType";
	Return This;
EndFunction // TaskProperties()

Function TaskChildObjects()
	This = Object();
	Items = This.Items;
	Items["Attribute"]            = "Attribute";
	Items["TabularSection"]       = "TabularSection";
	Items["Form"]                 = "String";
	Items["Template"]             = "String";
	Items["AddressingAttribute"]  = "AddressingAttribute";
	Items["Command"]              = "Command";
	Return This;
EndFunction // TaskChildObjects()

#EndRegion // Task

#Region WebService

Function WebService()
	This = Record(MDObjectBase());
	This["Properties"] = WebServiceProperties();
	This["ChildObjects"] = WebServiceChildObjects();
	Return This;
EndFunction // WebService()

Function WebServiceProperties()
	This = Record();
	This["Name"]                = "String";
	This["Synonym"]             = "LocalStringType";
	This["Comment"]             = "String";
	This["Namespace"]           = "String";
	//This["XDTOPackages"]        = "ValueList";
	This["DescriptorFileName"]  = "String";
	This["ReuseSessions"]       = Enums.SessionReuseMode;
	This["SessionMaxAge"]       = "Decimal";
	Return This;
EndFunction // WebServiceProperties()

Function WebServiceChildObjects()
	This = Object();
	Items = This.Items;
	//Items["Operation"] = ;
	Return This;
EndFunction // WebServiceChildObjects()

#EndRegion // WebService

#Region WSReference

Function WSReference()
	This = Record(MDObjectBase());
	This["Properties"] = WSReferenceProperties();
	This["ChildObjects"] = WSReferenceChildObjects();
	Return This;
EndFunction // WSReference()

Function WSReferenceProperties()
	This = Record();
	This["Name"]         = "String";
	This["Synonym"]      = "LocalStringType";
	This["Comment"]      = "String";
	This["LocationURL"]  = "String";
	Return This;
EndFunction // WSReferenceProperties()

Function WSReferenceChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // WSReferenceChildObjects()

#EndRegion // WSReference

#Region XDTOPackage

Function XDTOPackage()
	This = Record(MDObjectBase());
	This["Properties"] = XDTOPackageProperties();
	This["ChildObjects"] = XDTOPackageChildObjects();
	Return This;
EndFunction // XDTOPackage()

Function XDTOPackageProperties()
	This = Record();
	This["Name"]       = "String";
	This["Synonym"]    = "LocalStringType";
	This["Comment"]    = "String";
	This["Namespace"]  = "String";
	Return This;
EndFunction // XDTOPackageProperties()

Function XDTOPackageChildObjects()
	This = Object();
	Items = This.Items;

	Return This;
EndFunction // XDTOPackageChildObjects()

#EndRegion // XDTOPackage

#EndRegion // MetaDataObject

#Region LogForm

Function LogForm()
	This = Record();
	This["Width"] = "Decimal";
	This["Height"] = "Decimal";
	This["VerticalScroll"] = Enums.VerticalFormScroll;
	This["WindowOpeningMode"] = Enums.FormWindowOpeningMode;
	This["Attributes"] = FormAttributes();
	This["Events"] = FormEvents();
	This["ChildItems"] = "FormChildItems";
	Return This
EndFunction // LogForm()

Function FormItemBase()
	This = Record();
	This["id"] = "Decimal";
	This["name"] = "String";
	Return This;
EndFunction // FormItemBase()

Function FormChildItems()
	This = Object();
	Items = This.Items;
	Items["UsualGroup"] = FormUsualGroup();
	Return This;
EndFunction // FormChildItems()

Function FormUsualGroup()
	This = Record(FormItemBase());
	This["HorizontalAlign"] = Enums.ItemHorizontalLocation;
	This["United"] = "Boolean";
	This["ShowTitle"] = "Boolean";
	This["ChildItems"] = "FormChildItems";
	Return This;
EndFunction // FormUsualGroup()

#Region Events

Function FormEvents()
	This = Object();
	Items = This.Items;
	Items["Event"] = FormEvent();
	Return This;
EndFunction // FormEvents()

Function FormEvent()
	This = Record();
	This["name"] = "String";
	This["_"] = "String";
	Return This;
EndFunction // FormEvent()

#EndRegion // Events

#Region Attributes

Function FormAttributes()
	This = Object();
	Items = This.Items;
	Items["Attribute"] = FormAttribute();
	Return This;
EndFunction // FormAttributes()

Function FormAttribute()
	This = Record();
	This["name"] = "String";
	This["Title"] = "LocalStringType";
	This["SavedData"] = "Boolean";
	This["Columns"] = FormAttributeColumns();
	Return This;
EndFunction // FormAttribute()

#Region Columns

Function FormAttributeColumns()
	This = Object();
	Items = This.Items;
	Items["Column"] = FormAttributeColumn();
	Return This;
EndFunction // FormAttributeColumns()

Function FormAttributeColumn()
	This = Record();
	This["name"] = "String";
	This["Title"] = "LocalStringType";
	Return This;
EndFunction // FormAttributeColumn()

#EndRegion // Columns

#EndRegion // Attributes

#EndRegion // LogForm
