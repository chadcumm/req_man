/******************************************************************************************
 Client: PHSA_CD
 File:    custom-components.js
 Team:    Edge Professional Services

 Table of Contents:
 *    CernerSubsections				Plugin
 *	  Component Table				Plugin
 *    phsa_cd.intraopltd            Custom Component
 *    phsa_cd.proc_info				Custom Component 
 *    Blood Product Availability	Custom Component
 *******************************************************************************************
 CONTROL LOG
 *******************************************************************************************
 Date        Engineer ID            Comment
 ----------  -------------------    ---------------------------------------------
 05/24/2017  PB046730               Initial release - Lines, Tubes, Drains
 08/01/2017  PB046730               Initial release - Pre-Anesthesia Note, CernerSubsections
 03/13/2018  SS029666               Initial release - Blood Product Availability, CernerSubsections, Component table
 04/11/2018  PB046730		    Initial release - Problem List (Temporary for Nomenclatures)
 07/16/2018  TRAVIS.CAZES	    Initial release - Code Status Custom component
 07/18/2019  John Simpson	    Initial release - Anesthesia Patient Screening History
 10/16/2019  John Simpson	    Initial release - Custom Table Control
 10/16/2019  John Simpson	    Initial release - Oncology Medication Dispense
 12/01/2020  Chad Cummings 	    Initial Release - iPPDF
 04/07/2021  Chad Cummings	    Initial Release = iPPDF Dev
 02/01/2021  John Simpson	    Added date formatting to custom table control
 02/24/2021  John Simpson	    Initial Release - Transfusion Information
 07/20/2021  Chad Cummings	    Initial Release = iPPDF RM v1
 07/27/2021  John Simpson	    Initial Release - Intraoperative Medications
 08/18/2021  John Simpson	    Initial Release - iFrameResizer, Clinical Office Embed and Patient Information Component
 09/23/2021  John Simpson  	    Initial Release - Premature Infant Hyperbilirubinemia graph
 *******************************************************************************************/
/* THIS CODE WILL OVERWRITE STANDARD CODE FOUND IN MASTER-CORE-UTIL.JS */
/*
(function () {
	var CclString = MPageEntity.EncodedString;
	var CclNumber = MPageEntity.Number;
	var DateTime = MPageEntity.DateTime;
	var Entity = MPageEntity.Entity;
	var OneToOne = MPageEntity.OneToOne;
	var OneToMany = MPageEntity.OneToMany;
	var CodeValueField = MPageEntity.CodeValueField;
	var CodeSets = MPageEntity.CodeSets;
	var CclBool = MPageEntity.CclBool;
	var EncodedString = MPageEntity.EncodedString;
	Entity.create(MPageEntity.entities, "Nomenclature", {fields: {id: new CclNumber(),cmti: new CclString(),conceptCki: new CclString(),conceptIdentifier: new CclString(),conceptSource: new CodeValueField(CodeSets.NOMENCLATUREIDENTIFIERSOURCE),contributorSystem: new CodeValueField(CodeSets.CONTRIBUTORSYSTEM),language: new CodeValueField(CodeSets.LANGUAGE),mnemonic: new CclString(),primaryCTerm: new CclBool(),primaryVTerm: new CclBool(),principleType: new CodeValueField(CodeSets.PRINCIPLETYPE),shortString: new CclString(),sourceIdentifier: new CclString(),sourceIdentifierKeycap: new CclString(),sourceString: new CclString(),sourceStringKeycap: new CclString(),sourceVocabulary: new CodeValueField(CodeSets.SOURCEVOCABULARY),stringIdentifier: new CclString(),stringSource: new CodeValueField(CodeSets.NOMENCLATUREIDENTIFIERSOURCE),stringStatus: new CodeValueField(CodeSets.STRINGSTATUS),vocabAxis: new CodeValueField(CodeSets.SOURCEVOCABULARYAXIS),isSpecific: new CclBool()},actions: {search: {searchTerm: new EncodedString(),sourceFlag: new CclNumber(),resultLimit: new CclNumber()},list: {sourceStringEquals: new CclString(),sourceStringContains: new CclString(),mnemonicContains: new CclString(),languageId: new CclNumber(),idGreaterThan: new CclNumber()}}});
	MPageEntity.entities.Nomenclature.protocol = new MPageEntity.protocol.EntityProtocolV2();
	MPageEntity.Nomenclature = MPageEntity.entities.Nomenclature;
	MPageEntity.entities.Nomenclature.search = function (params, callback, async) {return MPageEntity.entities.Nomenclature.action("search", params, callback, async);
	};
	Entity.create(MPageEntity.entities, "NomenclaturePHSA", {fields: {id: new CclNumber(),cmti: new CclString(),conceptCki: new CclString(),conceptIdentifier: new CclString(),conceptSource: new CodeValueField(CodeSets.NOMENCLATUREIDENTIFIERSOURCE),contributorSystem: new CodeValueField(CodeSets.CONTRIBUTORSYSTEM),language: new CodeValueField(CodeSets.LANGUAGE),mnemonic: new CclString(),primaryCTerm: new CclBool(),primaryVTerm: new CclBool(),principleType: new CodeValueField(CodeSets.PRINCIPLETYPE),shortString: new CclString(),sourceIdentifier: new CclString(),sourceIdentifierKeycap: new CclString(),sourceString: new CclString(),sourceStringKeycap: new CclString(),sourceVocabulary: new CodeValueField(CodeSets.SOURCEVOCABULARY),stringIdentifier: new CclString(),stringSource: new CodeValueField(CodeSets.NOMENCLATUREIDENTIFIERSOURCE),stringStatus: new CodeValueField(CodeSets.STRINGSTATUS),vocabAxis: new CodeValueField(CodeSets.SOURCEVOCABULARYAXIS),isSpecific: new CclBool()},actions: {search: {searchTerm: new EncodedString(),sourceFlag: new CclNumber(),resultLimit: new CclNumber()},list: {sourceStringEquals: new CclString(),sourceStringContains: new CclString(),mnemonicContains: new CclString(),languageId: new CclNumber(),idGreaterThan: new CclNumber()}}});
	MPageEntity.entities.NomenclaturePHSA.protocol = new MPageEntity.protocol.EntityProtocolV2();
	MPageEntity.NomenclaturePHSA = MPageEntity.entities.NomenclaturePHSA;
	MPageEntity.entities.NomenclaturePHSA.search = function (params, callback, async) {return MPageEntity.entities.NomenclaturePHSA.action("search", params, callback, async);
	};
})();

(function ($) {
	var inherits = MPageObjectOriented.inherits;
	var attribute = MPageObjectOriented.createAttribute;
	var ns = MPageControls;
	MPageControls.NomenclatureSearch = function (element) {
		ns.AutoSuggest.call(this, element);
		this.setICD10CodeValues([]);
	};
	inherits(ns.NomenclatureSearch, ns.AutoSuggest);
	attribute(ns.NomenclatureSearch, "SuggestionLimit");
	attribute(ns.NomenclatureSearch, "SourceFlag");
	attribute(ns.NomenclatureSearch, "IsEnabled");
	attribute(ns.NomenclatureSearch, "ICD10CodeValues");
	attribute(ns.NomenclatureSearch, "SourceVocabCodeValue");
	var prot = MPageControls.NomenclatureSearch.prototype;
	var vocabMeaningToFlagMap = {
		ICD9: 1,
		SNMCT: 2,
		IMO: 3,
		"HLI.PFT": 5,
		MAYO_PROB: 6,
		"ICD10-CM": 7,
        DSM5: 13,
		"DSM5-CA": 13,
		CEDDX: 14,
		"CEDDXS.CST": 14
	};
	var isICD10Vocab = function (codevalue) {
		var icd10cvs = this.getICD10CodeValues();
		for (var i = icd10cvs.length;
			i--; ) {
			if (icd10cvs[i] == codevalue.getId()) {
				return true;
			}
		}
		return false;
	};
	var getVocabMeaning = function (codevalue) {
		if (!codevalue.getMeaning()) {
			codevalue.refresh();
		}
		return codevalue.getMeaning();
	};
	var retrieveSearchFlagFromCodeValue = function () {
		var sourceVocab = this.getSourceVocabCodeValue();
		if (isICD10Vocab.call(this, sourceVocab)) {
			return 7;
		}
		var meaning = getVocabMeaning.call(this, sourceVocab);
		var flag = vocabMeaningToFlagMap[meaning];
		if (!flag) {
			var err = new Error("The " + meaning + " vocabulary is not supported as a search target.");
			if (logger && logger.logJSError) {
				logger.logJSError(err, this, "nomenclature-search.js", "retrieveSearchFlagFromCodeValue");
			}
			throw err;
		}
		return flag;
	};
	prot.init = function () {
		MPageControls.AutoSuggest.prototype.init.call(this);
		var self = this;
		var list = this.getList();
		if (!this.getSuggestionLimit()) {
			this.setSuggestionLimit(10);
		}
		this.setDelay(500);
		this.setListItemTemplate(MPageControls.getDefaultTemplates().nomenSearchItem);
		this.setListTemplate(MPageControls.getDefaultTemplates().autoSuggestList);
		this.setIsEnabled(true);
		this.setOnDelay(function () {
			self.searchNomens();
		});
		this.getList().getElement().hover(function () {
			list.getElement().find("." + list.getHighlightClass()).removeClass(list.getHighlightClass());
		});
	};
	prot.disable = function () {
		var inputWrapper = this.getElement().find(".auto-suggest.input");
		var textBox = this.getTextbox();
		inputWrapper.toggleClass("disabled", true);
		this.deactivateCaption();
		textBox.prop("disabled", true);
		this.setIsEnabled(false);
	};
	prot.enable = function () {
		var inputWrapper = this.getElement().find(".auto-suggest.input");
		var textBox = this.getTextbox();
		inputWrapper.toggleClass("disabled", false);
		this.activateCaption();
		textBox.prop("disabled", false);
		this.setIsEnabled(true);
	};
	prot.searchNomens = function () {
		var searchTerm = this.getValue();
		var sourceFlag = this.getSourceFlag();
		var searchLimit = this.getSuggestionLimit();
		var closeBtnId = this.getClosebtnId();
		var closeBtn = $("#" + closeBtnId);
		var self = this;
		if (!sourceFlag) {
			throw "[*ERROR*] NomenSearch: No source flag specified.";
		}
		closeBtn.toggleClass("close-btn");
		closeBtn.toggleClass("loading-icon");
		MPageEntity.entities.NomenclaturePHSA.search({
			searchTerm: searchTerm,
			sourceFlag: sourceFlag,
			resultLimit: searchLimit
		}, function (hR, r, e) {
			self.handleReplyList(hR, r, e);
		}, true);
	};
	prot.handleReplyList = function (replyList, reply, err) {
	var closeBtnId = this.getClosebtnId();
		var closeBtn = $("#" + closeBtnId);
		var list = this.getList();
		var detailDialog = this.getDetailDialog();
		if (!list.getElement() || !detailDialog || !this.getValue() || !this.getElement()) {
			return;
		}
		if (!replyList) {
			throw (err);
		}
		closeBtn.toggleClass("close-btn");
		closeBtn.toggleClass("loading-icon");
		if (replyList.length <= 0) {
			this.setListTemplate(MPageControls.getDefaultTemplates().emptyList);
			var listHTML = list.getListTemplate().render();
			list.getElement().empty();
			list.getElement().append(listHTML);
			detailDialog.show();
			detailDialog.updatePosition();
		} else {
			this.setListTemplate(MPageControls.getDefaultTemplates().autoSuggestList);
			this.setSuggestions(replyList);
			list.setSelectedItem(replyList[0]);
		}
	};
	prot.getSourceFlag = function () {
		if (this.m_SourceFlag) {
			return this.m_SourceFlag;
		}
		return retrieveSearchFlagFromCodeValue.call(this);
	};
})(jQuery);
*/
/* END OF CODE THAT WILL OVERWRITE STANDARD CODE FOUND IN MASTER-CORE-UTIL.JS */

/*Subsection plugin*/
(function($){$.extend({CernerSubSecDefault:{"title":"Header","subTitle":"","content":"","isExpand":true,"canCollapseExpand":true,"className":""}});$.fn.extend({initSubSecToggle:function(){var tObj=$(this),tgl=$(".sub-sec-hd-tgl",tObj);tgl.click(function(){var parent=$(this).parent().parent();if(parent.hasClass("closed")){parent.removeClass("closed")}else{parent.addClass("closed")}})},cernerSubHeader:function(str){return $(this).append(["<div class='sub-title-disp' style='margin:-6px -6px 6px -6px;border-left:none;border-right:none;'>",str,"</div>"].join(""))},cernerSubSection:function(){var arrList=(arguments.length>1)?arguments:arguments[0],paramLen=arrList.length,retStr=[];for(var ssCnt=0;ssCnt<paramLen;ssCnt++){var arg=(typeof(arrList[ssCnt])=="object")?$.extend({},$.CernerSubSecDefault,arrList[ssCnt]):$.CernerSubSecDefault,cName=(arg.className&&arg.className!="")?arg.className+" ":"";retStr.push("<div class='",cName,"sub-sec",(!arg.isExpand?" closed":""),"'>","<div class='sub-sec-hd'>",(arg.canCollapseExpand?"<span class='sub-sec-hd-tgl'></span>":""),"<span class='sub-sec-title'>","<span class='comp-header-name'>",arg.title," </span>","<span class='sub-sec-total'>",arg.subTitle,"</span>","</span>","</div>","<div class='sub-sec-content'><div class='content-body'>",arg.content,"</div></div>","</div>")}return $(this).append(retStr.join("")).initSubSecToggle()}})})(jQuery);

/*Component table plugin.*/
if(typeof(EPS)==="undefined"){EPS=function(){};}
EPS.Template=function(){this.id="";this.templateFunction=null;}
EPS.Template.prototype.setId=function(id){this.id=id;};EPS.Template.prototype.getId=function(){return this.id;};EPS.Template.prototype.setTemplateFunction=function(templateFunction){this.templateFunction=templateFunction;};EPS.Template.prototype.getTemplateFunction=function(){return this.templateFunction;};EPS.Template.prototype.render=function(data){data=data||{};try{return this.templateFunction(data);}catch(exe){throw new Error("There was an error rendering the template: "+exe.message);}};EPS.TemplateBuilder=function(){}
EPS.TemplateBuilder.buildTemplate=function(template){if(typeof template!=="string"&&!$.isFunction(template)){throw new Error("Called buildTemplate on TemplateBuilder with non string/non function type for template parameter");}
var newTemplate=new EPS.Template();var templateFunction=template;if(typeof template==="string"){template=template.replace(/"/g,'\\"');templateFunction=new Function("data",'var params=[];params.push("'+template.split("${").join('");params.push(data.').split("}").join(');params.push("')+'");return params.join("");');}
newTemplate.setTemplateFunction(templateFunction);return newTemplate;};EPS.TemplateBuilder.buildAndCacheTemplate=function(id,template){var templateObject=EPS.TemplateBuilder.buildTemplate(template);EPS.TemplateCache.cacheTemplate(id,templateObject);return templateObject;};EPS.TemplateCache=function(){}
EPS.TemplateCache.templates={};EPS.TemplateCache.loadStandardTemplates=function(){for(var templateKey in EPS.StandardTemplates){var template=EPS.StandardTemplates[templateKey];if(template&&typeof template==="string"){EPS.TemplateCache.cacheTemplate(templateKey,EPS.TemplateBuilder.buildTemplate(template));}}};EPS.TemplateCache.cacheTemplate=function(id,template){if(typeof id!=="string"){throw new Error("Called cacheTemplate on TemplateCache with non string type for id parameter");}
if(!EPS.Template.prototype.isPrototypeOf(template)){throw new Error("Called cacheTemplate on TemplateCache with non Template type for template parameter");}
if(EPS.TemplateCache.hasTemplate(id)){throw new Error("Called cacheTemplate on TemplateCache. Template with id: "+id+" already exists. Please use a different identifier.");}
EPS.TemplateCache.templates[id]=template;};EPS.TemplateCache.getTemplate=function(id){if(!EPS.TemplateCache.hasTemplate(id)){throw new Error("Template with id: "+id+" does not exist");}
return EPS.TemplateCache.templates[id];};EPS.TemplateCache.hasTemplate=function(id){return(typeof EPS.TemplateCache.templates[id]!=="undefined"&&EPS.TemplateCache.templates[id]!==null);};EPS.MPageTooltip=function(){this.anchor=null;this.content=null;this.flipfit=true;this.height=0;this.offsetX=20;this.offsetY=20;this.showDelay=500;this.tolerance=5;this.stillHovered=false;this.width=0;this.x=0;this.y=0;return this;}
EPS.MPageTooltip.prototype.getAnchor=function(){return this.anchor;};EPS.MPageTooltip.prototype.setAnchor=function(anchor){this.anchor=anchor;return this;};EPS.MPageTooltip.prototype.getContent=function(){return this.content;};EPS.MPageTooltip.prototype.setContent=function(content){this.content=$("<div class='mpage-tooltip'>").html(content).hide();return this;};EPS.MPageTooltip.prototype.shouldFlipfit=function(){return this.flipfit;};EPS.MPageTooltip.prototype.setShouldFlipfit=function(flipfit){if(typeof flipfit!=="boolean"){throw new Error("Called setShouldFlipfit on EPS.MPageTooltip with non boolean type for flipfit parameter");}
this.flipfit=flipfit;return this;};EPS.MPageTooltip.prototype.getHeight=function(){return this.height;};EPS.MPageTooltip.prototype.setHeight=function(height){if(typeof height!=="number"){throw new Error("Called setHeight on EPS.MPageTooltip with non number type for height parameter");}
this.height=height;return this;};EPS.MPageTooltip.prototype.getOffsetX=function(){return this.offsetX;};EPS.MPageTooltip.prototype.setOffsetX=function(offsetX){if(typeof offsetX!=="number"){throw new Error("Called setOffsetX on EPS.MPageTooltip with non number type for offsetX parameter");}
this.offsetX=offsetX;return this;};EPS.MPageTooltip.prototype.getOffsetY=function(){return this.offsetY;};EPS.MPageTooltip.prototype.setOffsetY=function(offsetY){if(typeof offsetY!=="number"){throw new Error("Called setOffsetY on EPS.MPageTooltip with non number type for offsetY parameter");}
this.offsetY=offsetY;return this;};EPS.MPageTooltip.prototype.getShowDelay=function(){return this.showDelay;};EPS.MPageTooltip.prototype.setShowDelay=function(showDelay){if(typeof showDelay!=="number"){throw new Error("Called setShowDelay on EPS.MPageTooltip with non number type for showDelay parameter");}
if(showDelay<0){throw new Error("Called setShowDelay on EPS.MPageTooltip with negative value, showDelay must be > 0");}
this.showDelay=showDelay;return this;};EPS.MPageTooltip.prototype.isStillHovered=function(){return this.stillHovered;};EPS.MPageTooltip.prototype.setIsStillHovered=function(stillHovered){if(typeof stillHovered!=="boolean"){throw new Error("Called setIsStillHovered on EPS.MPageTooltip with non boolean type for stillHovered parameter");}
this.stillHovered=stillHovered;return this;};EPS.MPageTooltip.prototype.getTolerance=function(){return this.tolerance;};EPS.MPageTooltip.prototype.setTolerance=function(tolerance){if(typeof tolerance!=="number"){throw new Error("Called setTolerance on EPS.MPageTooltip with non number type for tolerance parameter");}
this.tolerance=tolerance;};EPS.MPageTooltip.prototype.getWidth=function(){return this.width;};EPS.MPageTooltip.prototype.setWidth=function(width){if(typeof width!=="number"){throw new Error("Called setWidth on EPS.MPageTooltip with non number type for width parameter");}
this.width=width;return this;};EPS.MPageTooltip.prototype.getX=function(){return this.x;};EPS.MPageTooltip.prototype.setX=function(x){if(typeof x!=="number"){throw new Error("Called setX on EPS.MPageTooltip with non number type for x parameter");}
this.x=x;return this;};EPS.MPageTooltip.prototype.getY=function(){return this.y;};EPS.MPageTooltip.prototype.setY=function(y){if(typeof y!=="number"){throw new Error("Called setY on EPS.MPageTooltip with non number type for y parameter");}
this.y=y;return this;};EPS.MPageTooltip.prototype.show=function(){var self=this;this.stillHovered=true;$(this.getAnchor()).on("mouseleave.discernTooltip",function(event){self.setIsStillHovered(false);if(self.getContent()){self.getContent().remove();}
$(self.getAnchor()).unbind(".discernTooltip");});setTimeout(function(){self.checkAnchorStillExists();if(!self.isStillHovered()){return;}
$(document.body).append(self.getContent());self.setHeight(self.getContent().height());self.setWidth(self.getContent().width());self.getContent().css({left:self.calculatePosition(self.x,$(window).width()-self.getTolerance(),self.width,self.getOffsetX()),top:self.calculatePosition(self.y,$(window).height()-self.getTolerance(),self.height,self.getOffsetY())});self.content.show();$(self.getAnchor()).on("mousemove.discernTooltip",function(event){if(!self.isStillHovered()){return;}
self.setX(event.pageX).setY(event.pageY);self.content.css("left",self.calculatePosition(event.pageX,$(window).width()-self.getTolerance(),self.width,self.getOffsetX()));self.content.css("top",self.calculatePosition(event.pageY,$(window).height()-self.getTolerance(),self.height,self.getOffsetY()));});},this.getShowDelay());};EPS.MPageTooltip.prototype.calculatePosition=function(mouseValue,windowValue,tooltipValue,paramOffset){if(this.shouldFlipfit()&&mouseValue+paramOffset>(windowValue-tooltipValue)){var positionVal=mouseValue-tooltipValue-paramOffset;if(positionVal<0){positionVal=((windowValue)/2)-(tooltipValue/2);}
return positionVal;}
return mouseValue+paramOffset;};EPS.MPageTooltip.prototype.checkAnchorStillExists=function(){var self=this;function checkHoverAnchor(){try{if(!$(document.body).find(self.getAnchor()).length){self.getContent().remove();self.setIsStillHovered(false);return;}
if(!self.isStillHovered()){return;}
setTimeout(checkHoverAnchor,5000);}catch(exe){return;}}
checkHoverAnchor();};EPS.ComponentTable=function(noResultsString){this.activeRows=null;this.bodyTag="div";this.columns=null;this.columnMap=null;this.columnTag="dd";this.cssTemplate="list-as-table";this.currentlySortedBy=null;this.currentlySortedColumn=null;this.customClass="";this.extensions=null;this.groupedBy="";this.groupMap=null;this.groupSequence=null;this.groupTemplate=null;this.headerEnabled=true;this.namespace="";this.noResultsString=(noResultsString)?noResultsString:"No Results Found";this.hideSectionStr="Hide Section";this.showSectionStr="Show Section";this.rowDataAttr=null;this.rowDataTemplate=null;this.rows=null;this.rowMap=null;this.rowTag="dl";this.sequence=null;this.showGroupCount=false;this.sortable=false;this.zebraStripe=true;}
EPS.ComponentTable.prototype.setDataAttributeOnRow=function(attrName,attrTemplate){if(typeof attrName!="string"||$.trim(attrName)==""){throw new Error("Called setDataAttributeOnRow on ComponentTable with non String type for attrName parameter");}
this.rowDataAttr=attrName;this.rowDataTemplate=EPS.TemplateBuilder.buildTemplate(attrTemplate);return this;};EPS.ComponentTable.prototype.getDataAttributeOnRow=function(data){if(this.rowDataAttr===null||this.rowDataTemplate===null){return"";}
return" "+this.rowDataAttr+"=\""+this.rowDataTemplate.render(data)+"\"";};EPS.ComponentTable.prototype.getActiveRows=function(){if(!this.activeRows){this.activeRows=[];}
return this.activeRows;};EPS.ComponentTable.prototype.setActiveRows=function(activeRows){if(!(activeRows instanceof Array)){throw new Error("Called setActiveRows on EPS.ComponentTable with non Array type for activeRows parameter");}
this.activeRows=activeRows;return this;};EPS.ComponentTable.prototype.addColumn=function(column){if(!EPS.TableColumn.prototype.isPrototypeOf(column)){throw new Error("Called addColumn on ComponentTable with non EPS.TableColumn type for column parameter");}
if(this.hasColumn(column.getColumnId())){throw new Error("Column with id: "+column.getColumnId()+" already exists in the EPS.ComponentTable with namespace: "+this.namespace);}
if(column.getIsSortable()){this.sortable=true;}
this.getColumnSequence().push(column.getColumnId());this.getColumns().push(column);this.getColumnMap()[column.getColumnId()]=column;};EPS.ComponentTable.prototype.getColumns=function(){if(!this.columns){this.columns=[];}
return this.columns;};EPS.ComponentTable.prototype.getColumnMap=function(){if(!this.columnMap){this.columnMap={};}
return this.columnMap;};EPS.ComponentTable.prototype.getColumnAtIndex=function(index){if(index<0||index>=this.getColumns().length){throw new Error("Index out of bounds when calling getColumnAtIndex on EPS.ComponentTable. Used index: "+index);}
return this.getColumns()[index];};EPS.ComponentTable.prototype.getColumnById=function(columnId){if(!this.hasColumn(columnId)){throw new Error("In EPS.ComponentTable method getColumnById, EPS.TableColumn with columnId: "+columnId+" does not exist");}
return this.getColumnMap()[columnId];};EPS.ComponentTable.prototype.hasColumn=function(columnId){return(typeof this.getColumnMap()[columnId]!=="undefined"&&this.getColumnMap()[columnId]!==null);};EPS.ComponentTable.prototype.getColumnTag=function(){return this.columnTag;};EPS.ComponentTable.prototype.setColumnTag=function(columnTag){if(typeof columnTag!=="string"){throw new Error("Called setColumnTag on EPS.ComponentTable with non string type for columnTag parameter");}
this.columnTag=columnTag;return this;};EPS.ComponentTable.prototype.getCSSTemplate=function(){return this.cssTemplate;};EPS.ComponentTable.prototype.setCSSTemplate=function(cssTemplate){if(typeof cssTemplate!=="string"){throw new Error("Called setCSSTemplate on EPS.ComponentTable with non string type for cssTemplate parameter");}
this.cssTemplate=cssTemplate;return this;};EPS.ComponentTable.prototype.setBodyTag=function(bodyTag){if(typeof bodyTag!=="string"){throw new Error("Called setBodyTag on EPS.ComponentTable with non string type for bodyTag parameter");}
this.bodyTag=bodyTag;return this;};EPS.ComponentTable.prototype.getBodyTag=function(){return this.bodyTag;};EPS.ComponentTable.prototype.setNoresultsString=function(noResultsString){if(typeof noResultsString!=="string"){throw new Error("Called setNoresultsFound on EPS.ComponentTable with non string type for noResultsString parameter");}
this.noResultsString=noResultsString;return this;};EPS.ComponentTable.prototype.getNoResultsString=function(){return this.noResultsString;};EPS.ComponentTable.prototype.getRowTag=function(){return this.rowTag;};EPS.ComponentTable.prototype.setRowTag=function(rowTag){if(typeof rowTag!=="string"){throw new Error("Called setRowTag on EPS.ComponentTable with non string type for rowTag parameter");}
this.rowTag=rowTag;return this;};EPS.ComponentTable.prototype.afterSort=function(){};EPS.ComponentTable.prototype.sortByColumnInDirection=function(columnId,direction){if(!this.hasColumn(columnId)){throw new Error("In EPS.ComponentTable method toggleColumnSort, EPS.TableColumn with columnId: "+columnId+" does not exist\nOptions are: "+this.getColumnSequence().join(","));}
if(!EPS.TableColumn.isValidSortDirection(direction)){throw new Error("Called sortByColumnInDirection on EPS.ComponentTable with invalid sort direction. Use enumeration EPS.TableColumn.SORT.ASCENDING or EPS.TableColumn.SORT.DESCENDING");}
var column=this.getColumnMap()[columnId];if(!column.getIsSortable()){return;}
var sortFunction=EPS.ColumnSortFactory.getSortFunction(column,direction);this.currentlySortedBy=sortFunction;this.updateSortIndicators(column,direction);this.getRows().sort(sortFunction);this.getActiveRows().sort(sortFunction);this.sortGroups(sortFunction);this.refresh();this.afterSort();};EPS.ComponentTable.prototype.toggleColumnSort=function(columnId){if(!this.hasColumn(columnId)){throw new Error("In EPS.ComponentTable method toggleColumnSort, EPS.TableColumn with columnId: "+columnId+" does not exist.\nOptions are: "+this.getColumnSequence().join(","));}
var column=this.getColumnMap()[columnId];if(!column.getIsSortable()){return;}
var sortDirection=(column.getColumnSortDirection()!==EPS.TableColumn.SORT.NONE?(-1*column.getColumnSortDirection()):column.getDefaultSort());this.sortByColumnInDirection(columnId,sortDirection);};EPS.ComponentTable.prototype.updateSortIndicators=function(column,direction){var ns=this.namespace;var sortedColumn=this.getCurrentlySortedColumn();if(sortedColumn){$("#"+ns+"columnHeader"+sortedColumn.getColumnId()).removeClass(this.getSortClass(sortedColumn.getColumnSortDirection()));sortedColumn.setColumnSortDirection(EPS.TableColumn.SORT.NONE);}
$("#"+ns+"columnHeader"+column.getColumnId()).addClass(this.getSortClass(direction));column.setColumnSortDirection(direction);this.currentlySortedColumn=column;};EPS.ComponentTable.prototype.getSortClass=function(sortDirection){switch(sortDirection){case EPS.TableColumn.SORT.ASCENDING:return"sort-asc";case EPS.TableColumn.SORT.DESCENDING:return"sort-desc";default:return"";}};EPS.ComponentTable.prototype.getCurrentlySortedBy=function(){return this.currentlySortedBy;};EPS.ComponentTable.prototype.setCurrentlySortedBy=function(currentlySortedBy){if(typeof currentlySortedBy!=="function"){throw new Error("Called setCurrentlySortedBy on EPS.ComponentTable with non function type for currentlySortedBy parameter");}
this.currentlySortedBy=currentlySortedBy;return this;};EPS.ComponentTable.prototype.getCurrentlySortedColumn=function(){return this.currentlySortedColumn;};EPS.ComponentTable.prototype.setCurrentlySortedColumn=function(currentlySortedColumn){if(!EPS.TableColumn.prototype.isPrototypeOf(currentlySortedColumn)){throw new Error("Called setCurrentlySortedColumn on EPS.ComponentTable with non EPS.TableColumn type for currentlySortedColumn parameter");}
this.currentlySortedColumn=currentlySortedColumn;return this;};EPS.ComponentTable.prototype.getCustomClass=function(){return this.customClass;};EPS.ComponentTable.prototype.setCustomClass=function(customClass){if(typeof customClass!=="string"){throw new Error("Called setCustomClass on EPS.ComponentTable with non string type for customClass parameter");}
this.customClass=customClass;return this;};EPS.ComponentTable.prototype.addExtension=function(extension){if(!EPS.TableExtension.prototype.isPrototypeOf(extension)){throw new Error("Called addExtension on EPS.ComponentTable with non EPS.TableExtension type for extension parameter");}
this.getExtensions().push(extension);return this;};EPS.ComponentTable.prototype.getExtensions=function(){if(!this.extensions){this.extensions=[];}
return this.extensions;};EPS.ComponentTable.prototype.quickGroup=function(key,template,showCount){this.groupedBy=key;this.groupTemplate=EPS.TemplateBuilder.buildTemplate(template);this.showGroupCount=showCount;var tableRows=this.getRows();var numberOfRows=tableRows.length;if(!numberOfRows){return;}
this.groupSequence=[];this.groupMap={};for(var i=0;i<numberOfRows;i++){this.addRowToGroup(key,tableRows[i],showCount);}};EPS.ComponentTable.prototype.addRowToGroup=function(groupKey,row,showCount){var rowData=row.getResultData();var rowKey=(rowData[groupKey]||"UNKNOWN").replace(/[\s]/gi,"_").replace(/[\W]/gi,"").toUpperCase();var gMap=this.getGroupMap();var gSequence=this.getGroupSequence();if(!gMap[rowKey]){gMap[rowKey]=new EPS.TableGroup().setKey(groupKey).setValue(rowKey).setDisplay(this.groupTemplate.render(rowData)).setGroupId(rowKey).setShowCount(showCount);gSequence.push(rowKey);}
gMap[rowKey].addRow(row);};EPS.ComponentTable.prototype.isGroupingApplied=function(){return(this.getGroupSequence().length>0);};EPS.ComponentTable.prototype.addGroup=function(group){if(!EPS.TableGroup.prototype.isPrototypeOf(group)){throw new Error("Called addGroup on EPS.ComponentTable with non EPS.TableGroup type for group parameter");}
if(this.hasGroup(group.getGroupId())){throw new Error("In addGroup on EPS.ComponentTable, EPS.TableGroup with id: "+group.getGroupId()+" already exists");}
var gMap=this.getGroupMap();var gSequence=this.getGroupSequence();if(this.currentlySortedBy){group.getRows().sort(this.currentlySortedBy);}
gSequence.push(group.getGroupId());gMap[group.getGroupId()]=group;return this;};EPS.ComponentTable.prototype.applyGroups=function(groups){if(!(groups instanceof Array)){throw new Error("Called applyGroups on EPS.ComponentTable with non Array type for groups parameter");}
this.clearGroups();for(var i=0;i<groups.length;i++){this.addGroup(groups[i]);}};EPS.ComponentTable.prototype.sortGroups=function(sortFunction){var gMap=this.getGroupMap();var gSequence=this.getGroupSequence();var numberOfGroups=gSequence.length;for(var i=0;i<numberOfGroups;i++){gMap[gSequence[i]].getRows().sort(sortFunction);}};EPS.ComponentTable.prototype.hasGroup=function(groupId){return(typeof this.getGroupMap()[groupId]!=="undefined"&&this.getGroupMap()[groupId]!==null);};EPS.ComponentTable.prototype.getGroupById=function(groupId){if(!this.hasGroup(groupId)){throw new Error("In EPS.ComponentTable method getGroupById, EPS.TableGroup with groupId: "+groupId+" does not exist");}
return this.getGroupMap()[groupId];};EPS.ComponentTable.prototype.getGroupMap=function(){if(!this.groupMap){this.groupMap={};}
return this.groupMap;};EPS.ComponentTable.prototype.getGroupSequence=function(){if(!this.groupSequence){this.groupSequence=[];}
return this.groupSequence;};EPS.ComponentTable.prototype.openGroup=function(groupId){if(!this.hasGroup(groupId)){throw new Error("In EPS.ComponentTable method toggleGroup, EPS.TableGroup with groupId: "+groupId+" does not exist");}
var tableGroup=this.getGroupMap()[groupId];var groupContainer=$("#"+this.namespace+"\\:"+tableGroup.getGroupId());if(tableGroup.isExpanded()){return;}
tableGroup.setIsExpanded(true);groupContainer.removeClass("closed");groupContainer.find(".sub-sec-hd-tgl").attr("title",this.hideSectionStr).html("-");};EPS.ComponentTable.prototype.openGroups=function(groupIds){if(!(groupIds instanceof Array)){throw new Error("Called openGroups on EPS.ComponentTable with non Array type for groups parameter");}
for(var i=0;i<groupIds.length;i++){this.openGroup(groupIds[i]);}};EPS.ComponentTable.prototype.collapseGroup=function(groupId){if(!this.hasGroup(groupId)){throw new Error("In EPS.ComponentTable method toggleGroup, EPS.TableGroup with groupId: "+groupId+" does not exist");}
var tableGroup=this.getGroupMap()[groupId];var groupContainer=$("#"+this.namespace+"\\:"+tableGroup.getGroupId());if(!tableGroup.isExpanded()){return;}
tableGroup.setIsExpanded(false);groupContainer.addClass("closed");groupContainer.find(".sub-sec-hd-tgl").attr("title",this.showSectionStr).html("+");};EPS.ComponentTable.prototype.collapseGroups=function(groupIds){if(!(groupIds instanceof Array)){throw new Error("Called closeGroups on EPS.ComponentTable with non Array type for groups parameter");}
for(var i=0;i<groupIds.length;i++){this.collapseGroup(groupIds[i]);}};EPS.ComponentTable.prototype.toggleGroup=function(groupId){var group=this.getGroupById(groupId);if(group.isExpanded()){this.collapseGroup(groupId);}else{this.openGroup(groupId);}};EPS.ComponentTable.prototype.clearGroups=function(){this.groupSequence=[];this.groupMap={};this.groupedBy="";};EPS.ComponentTable.prototype.renderGroup=function(group){var headId=this.namespace+":"+group.getGroupId();var headToggleTitle=group.isExpanded()?this.hideSectionStr:this.showSectionStr;var headToggleContent=group.isExpanded()?"-":"+";var headToggleClass=group.isExpanded()?"":"closed";var countHtml=group.getShowCount()?"<span class='sub-sec-total'>&nbsp;("+group.getRows().length+")</span>":"";var toggleHtml=group.getCanCollapse()?("<span class='sub-sec-hd-tgl' title='"+headToggleTitle+"'>"+headToggleContent+"</span>"):"";var hideHeader=group.getHideHeader()?"hidden'":"";return"<div id='"+headId+"' class='"+headToggleClass+"'><h3 id='"+headId+":header' class='sub-sec-hd "+hideHeader+"'>"+toggleHtml+"<span class='sub-sec-title'><"+this.getRowTag()+"><"+this.getColumnTag()+"><span class='sub-sec-display'>"+group.getDisplay()+"</span>"+countHtml+"</"+this.getColumnTag()+"></"+this.getRowTag()+"></span></h3><div id='"+headId+":content' class='sub-sec-content'>"+(group.getRows().length?this.renderRows(group.getRows(),group.getGroupId()):this.renderNoResults())+"</div></div>";};EPS.ComponentTable.prototype.isHeaderEnabled=function(){return this.headerEnabled;};EPS.ComponentTable.prototype.setIsHeaderEnabled=function(headerEnabled){if(typeof headerEnabled!=="boolean"){throw new Error("Called setIsHeaderEnabled on EPS.ComponentTable with non boolean type for headerEnabled parameter");}
this.headerEnabled=headerEnabled;return this;};EPS.ComponentTable.prototype.getNamespace=function(){return this.namespace;};EPS.ComponentTable.prototype.setNamespace=function(namespace){if(typeof namespace!=="string"){throw new Error("Called setNamespace on EPS.ComponentTable with non string type for namespace parameter");}
this.namespace=namespace;return this;};EPS.ComponentTable.prototype.addRow=function(row){if(!EPS.TableRow.prototype.isPrototypeOf(row)){throw new Error("Called addRow on EPS.ComponentTable with non EPS.TableRow type for row parameter");}
this.getRows().push(row);return this;};EPS.ComponentTable.prototype.getRows=function(){if(!this.rows){this.rows=[];}
return this.rows;};EPS.ComponentTable.prototype.getRowById=function(rowId){if(!this.hasRow(rowId)){throw new Error("In EPS.ComponentTable method getRowById, EPS.TableRow with rowId: "+rowId+" does not exist");}
return this.getRowMap()[rowId];};EPS.ComponentTable.prototype.getRowMap=function(){if(!this.rowMap){this.rowMap={};}
return this.rowMap;};EPS.ComponentTable.prototype.hasRow=function(rowId){return(typeof this.getRowMap()[rowId]!=="undefined"&&this.getRowMap()[rowId]!==null);};EPS.ComponentTable.prototype.getColumnSequence=function(){if(!this.sequence){this.sequence=[];}
return this.sequence;};EPS.ComponentTable.prototype.getZebraStripe=function(){return this.zebraStripe;};EPS.ComponentTable.prototype.setZebraStripe=function(zebraStripe){if(typeof zebraStripe==="boolean"){this.zebraStripe=zebraStripe;}
return this;};EPS.ComponentTable.prototype.getStripeClass=function(index){if(!this.zebraStripe){return"";}
return(index%2===0)?"odd":"even";};EPS.ComponentTable.prototype.render=function(){var groupingClass=this.isGroupingApplied()?" grouping-applied":"";var contentBodyClass=groupingClass!==""||this.getActiveRows().length>0?"content-body":"";var customClass=this.getCustomClass()?" "+this.getCustomClass():"";var cssTemplate=this.getCSSTemplate()?" "+this.getCSSTemplate():"";var bodyHTML="<div id='"+this.namespace+"table' class='component-table"+cssTemplate+customClass+groupingClass+"'>"+(this.isHeaderEnabled()?this.renderHeader():"")+"<div  id='"+this.namespace+"tableBody' class='"+contentBodyClass+"'>"+this.renderBody()+"</div></div>";return bodyHTML;};EPS.ComponentTable.prototype.refresh=function(){var tableRoot=$("#"+this.namespace+"table");if(!tableRoot||!tableRoot.length){return;}
if(this.isGroupingApplied()){tableRoot.addClass("grouping-applied");}else{tableRoot.removeClass("grouping-applied");}
var tableBody=$("#"+this.namespace+"tableBody");if(!tableBody||!tableBody.length){return;}
tableBody[0].innerHTML=this.renderBody();this.updateAfterResize();};EPS.ComponentTable.prototype.renderHeader=function(){var ns=this.namespace;var gSequence=this.getGroupSequence();var numberOfGroups=gSequence.length;if(this.getActiveRows().length>0||numberOfGroups>0){var headerWrapper="<"+this.getBodyTag()+" id='"+ns+"headerWrapper' class='content-hdr'>";var headerHTML="<"+this.getRowTag()+" id='"+ns+"header' class='"+(this.sortable?"sort-control":"")+" hdr'>";var columnSequence=this.getColumnSequence();var numberColumns=columnSequence.length;var headerItemClass="";var column=null;var style="";for(var i=0;i<numberColumns;i++){headerItemClass="header-item";column=this.getColumnMap()[columnSequence[i]];style=column.getWidth()?" style='width:"+column.getWidth()+"px;'":"";headerItemClass+=(column.getCustomClass()?(" "+column.getCustomClass()):"");headerItemClass+=(column.getIsSortable()?" sort-option":"");if(column.getColumnSortDirection()!==EPS.TableColumn.SORT.NONE){headerItemClass+=(" "+this.getSortClass(column.getColumnSortDirection()));}
headerHTML+=("<"+this.getColumnTag()+" id='"+ns+"columnHeader"+column.getColumnId()+"' class='"+headerItemClass+"'"+style+"><span id='"+ns+"headerItemDisplay"+column.getColumnId()+"' class='header-item-display'>"+column.getColumnDisplay()+"</span></"+this.getColumnTag()+">");}
return headerWrapper+headerHTML+"</"+this.getRowTag()+"></"+this.getBodyTag()+">";}else{return"";}};EPS.ComponentTable.prototype.renderBody=function(){var tableBodyHTML="";var gMap=this.getGroupMap();var gSequence=this.getGroupSequence();var numberOfGroups=gSequence.length;if(!gSequence.length){if(this.getActiveRows().length>0){$("#"+this.namespace+"tableBody").addClass("content-body");return this.renderRows(this.getActiveRows(),null);}else{$("#"+this.namespace+"tableBody").removeClass("content-body");return this.renderNoResults();}}else{for(var i=0;i<numberOfGroups;i++){tableBodyHTML+=this.renderGroup(gMap[gSequence[i]]);}}
return tableBodyHTML;};EPS.ComponentTable.prototype.renderRows=function(rows,groupId){var rowsHtml="";var columnSequence=this.getColumnSequence();var numberColumns=columnSequence.length;var style="";groupId=groupId?(":"+groupId):"";var cellId="";for(var i=0;i<rows.length;i++){var row=rows[i];var rowData=row.getResultData();var rowClass="result-info "+this.getStripeClass(i);var rowId=this.namespace+groupId+":"+row.getId();rowsHtml+="<"+this.getRowTag()+this.getDataAttributeOnRow(rowData)+" id='"+rowId+"' class='"+rowClass+"'>";for(var j=0;j<numberColumns;j++){var column=this.getColumnMap()[columnSequence[j]];var tableCellClass="table-cell "+column.getCustomClass();var columnID=column.getColumnId();style=column.getWidth()?" style='width:"+column.getWidth()+"px;'":"";cellId=this.namespace+groupId+":"+row.getId()+":"+columnID;rowsHtml+="<"+this.getColumnTag()+" id='"+cellId+"' class='"+tableCellClass+"'"+style+">";rowsHtml+=(column.getRenderTemplate().render(rowData)||"<span>&nbsp;</span>");rowsHtml+="</"+this.getColumnTag()+">";}
rowsHtml+="</"+this.getRowTag()+">";}
return rowsHtml;};EPS.ComponentTable.prototype.renderNoResults=function(){return"<span class='res-none'>"+this.getNoResultsString()+"</span>";};EPS.ComponentTable.prototype.finalize=function(){var self=this;var extensionsList=this.getExtensions();var numberOfExtensions=extensionsList.length;var header=$("#"+this.namespace+"header").on("click",".sort-option",function(event){var id=$(this).attr("id");var prefixLength=(self.namespace+"columnHeader").length;var columnID=id.substring(prefixLength,id.length);self.toggleColumnSort(columnID);});$("#"+this.namespace+"tableBody").find(".sub-sec-hd-tgl").each(function(){Util.removeEvent(this,"click",MP_Util.Doc.ExpandCollapse);});$("#"+this.namespace+"tableBody").on("click",".sub-sec-hd",function(event){self.toggleGroup(EPS.TableGroup.parseGroupId($(this).attr("id")));self.updateAfterResize();});for(var i=0;i<numberOfExtensions;i++){extensionsList[i].finalize(this);}
var container=$("#"+this.namespace+"table").parent(),hasNoResults=(container.find(".mpage-no-results").length>0);if(hasNoResults){container.addClass("component-table-no-results");}};EPS.ComponentTable.prototype.updateAfterResize=function(){var tableBody=$("#"+this.namespace+"tableBody");if(!tableBody||!tableBody.length){return;}
if(tableBody[0].scrollHeight>tableBody.outerHeight()){$("#"+this.namespace+"header").addClass("shifted");}else{$("#"+this.namespace+"header").removeClass("shifted");}};EPS.ComponentTable.prototype.bindData=function(data){if(!this.getColumnSequence().length){throw new Error("Called bindData on EPS.ComponentTable with no columns defined.");}
if(typeof data!=="object"||!(data instanceof Array)){throw new Error("Called bindData on EPS.ComponentTable with non object Array type for data parameter. Please pass an Array of json results");}
this.clearData();var dataLength=data.length;var tableRows=this.getRows();var rMap=this.getRowMap();if(dataLength>0){for(var i=0;i<dataLength;i++){var dataItem=data[i];var tableRow=new EPS.TableRow().setId("row"+i).setResultData(dataItem);tableRows.push(tableRow);rMap[tableRow.getId()]=tableRow;if(this.groupedBy){this.addRowToGroup(this.groupedBy,tableRow,this.showGroupCount);}}
this.activeRows=tableRows;if(this.currentlySortedBy){this.getActiveRows().sort(this.currentlySortedBy);tableRows.sort(this.currentlySortedBy);this.sortGroups(this.currentlySortedBy);}}else{this.activeRows=[];}
return this;};EPS.ComponentTable.prototype.clearData=function(){this.rows=[];this.rowMap={};this.activeRows=[];};EPS.ColumnSortFactory=function(){}
EPS.ColumnSortFactory.getSortFunction=function(column,sortDirection){if(!EPS.TableColumn.isValidSortDirection(sortDirection)){throw new Error("Called EPS.ColumnSortFactory.getSortFunction with invalid sort direction. Use enumeration EPS.TableColumn.SORT.ASCENDING or EPS.TableColumn.SORT.DESCENDING");}
return function(rowA,rowB){var resultDataA=rowA.getResultData();var resultDataB=rowB.getResultData();var rowAVal=resultDataA[column.getPrimarySortField()];var rowBVal=resultDataB[column.getPrimarySortField()];var comparison=EPS.ColumnSortFactory.compare(rowAVal,rowBVal);if(comparison!==0){return sortDirection*comparison;}
var secondarySortFields=column.getSecondarySortFields();for(var i=0;i<secondarySortFields.length;i++){rowAVal=resultDataA[secondarySortFields[i].FIELD];rowBVal=resultDataB[secondarySortFields[i].FIELD];comparison=EPS.ColumnSortFactory.compare(rowAVal,rowBVal);if(comparison!==0){return secondarySortFields[i].DIRECTION*comparison;}}
return 0;};};EPS.ColumnSortFactory.compare=function(a,b){try{if(typeof a==="number"||typeof b==="number"){a=a||0;b=b||0;}else{if(typeof a==="string"||typeof b==="string"){a=(a||"").toUpperCase();b=(b||"").toUpperCase();}}
return((a>b)?-1:(a<b?1:0));}catch(exe){MP_Util.LogError("Called EPS.ColumnSortFactory.compare(a,b) with an invalid value for a or b");return 0;}};EPS.ComponentTableDataRetriever=function(){}
EPS.ComponentTableDataRetriever.getResultFromTable=function(table,element){var identifiers=$(element).attr("id").split(":");if(table.isGroupingApplied()){return table.getGroupById(identifiers[1]).getRowById(identifiers[2]).getResultData();}else{return table.getRowById(identifiers[1]).getResultData();}};EPS.ComponentTableDataRetriever.getColumnIdFromElement=function(table,element){if(!EPS.ComponentTable.prototype.isPrototypeOf(table)){throw new Error("Called getColumnIdFromElement on EPS.ComponentTableDataRetriever with non EPS.ComponentTable type for table parameter");}
var identifiers=$(element).attr("id").split(":");if(table.isGroupingApplied()){return(identifiers.length>4)?(identifiers.slice(3).join(":")):(identifiers[3]);}else{return(identifiers.length>3)?(identifiers.slice(2).join(":")):identifiers[2];}};EPS.SidePanel=function(){this.m_uniqueId=null;this.m_panelId=null;this.m_containerElementId=null;this.m_expandOption=this.expandOption.NONE;this.m_fullPanelScrollOn=true;this.m_regexHeightWidth=/^(\d+((px)|%){1})$/;this.m_height="175px";this.m_width="100%";this.m_maxHeight=null;this.m_minHeight="175px";this.m_previousMinHeight=null;this.m_mouseEnterFunc=null;this.m_mouseLeaveFunc=null;this.m_onExpandFunc=null;this.m_onCollapseFunc=null;this.m_parentContainer=null;this.m_sidePanelObj=null;this.m_sidePanelContents=null;this.m_sidePanelBodyContents=null;this.m_scrollContainer=null;this.m_expCollapseIconObj=null;this.m_expCollapseBarObj=null;this.m_sidePanelHeader=null;this.m_headerTitleObj=null;this.m_subtitleObj=null;this.m_closeButton=null;this.m_closeFunction=null;this.m_cornerCloseButton=null;this.m_cornerCloseFunction=null;this.m_usingUpdatedPanel=false;};EPS.SidePanel.prototype.getUniqueId=function(){return this.m_uniqueId;};EPS.SidePanel.prototype.setUniqueId=function(uniqueId){if(!uniqueId||(typeof uniqueId!=="string"&&typeof uniqueId!=="number")){logger.logError("Parameter uniqueId must be of type string or number for the EPS.SidePanel.setUniqueId function.");return;}
this.m_uniqueId=uniqueId;this.m_panelId="sidePanel"+uniqueId;return this;};EPS.SidePanel.prototype.getContainerElementId=function(){return this.m_containerElementId;};EPS.SidePanel.prototype.setContainerElementId=function(containerElementId){if(!containerElementId||typeof containerElementId!=="string"){logger.logError("Parameter containerElementId must be of type string for the EPS.SidePanel.setContainerElementId function.");return;}
this.m_containerElementId=containerElementId;return this;};EPS.SidePanel.prototype.getExpandOption=function(){return this.m_expandOption;};EPS.SidePanel.prototype.setExpandOption=function(expandOption){var valid=false;for(key in this.expandOption){var func=this.expandOption[key];if(expandOption===func){valid=true;break;}}
if(!valid){logger.logError("Parameter expandOption must be of type EPS.SidePanel.expandOption for the EPS.SidePanel.setExpandOption function.");return;}
this.m_expandOption=expandOption;return this;};EPS.SidePanel.prototype.getFullPanelScrollOn=function(){return this.m_fullPanelScrollOn;};EPS.SidePanel.prototype.setFullPanelScrollOn=function(scrollOn){if(typeof scrollOn!=="boolean"){logger.logError("Parameter scrollOn must be of type boolean for the EPS.SidePanel.setFullPanelScrollOn function.");return;}
this.m_fullPanelScrollOn=scrollOn;return this;};EPS.SidePanel.prototype.getWidth=function(){return this.m_width;};EPS.SidePanel.prototype.setWidth=function(newWidth){if(!this.m_regexHeightWidth.test(newWidth)){logger.logError("Parameter newWidth must match the regex /^(\d+((px)|%){1})$/ for the EPS.SidePanel.setWidth function.");return;}
this.m_width=newWidth;if(this.m_sidePanelObj&&this.m_sidePanelObj.length){this.m_sidePanelObj.css({width:this.m_width});}
return this;};EPS.SidePanel.prototype.getHeight=function(){return this.m_height;};EPS.SidePanel.prototype.setHeight=function(newHeight){if(!this.m_regexHeightWidth.test(newHeight)){logger.logError("Parameter newHeight must match the regex /^(\d+((px)|%){1})$/ for the EPS.SidePanel.setHeight function.");return;}
this.m_height=newHeight;if(this.m_sidePanelObj&&this.m_sidePanelObj.length){this.m_sidePanelObj.css({height:this.m_height});}
return this;};EPS.SidePanel.prototype.getMaxHeight=function(){return this.m_maxHeight;};EPS.SidePanel.prototype.setMaxHeight=function(newMaxHeight){if(!this.m_regexHeightWidth.test(newMaxHeight)){logger.logError("Parameter newMaxHeight must match the regex /^(\d+((px)|%){1})$/ for the EPS.SidePanel.setMaxHeight function.");return;}
this.m_maxHeight=newMaxHeight;if(this.m_sidePanelObj&&this.m_sidePanelObj.length){this.m_sidePanelObj.css({"max-height":this.m_maxHeight});}
return this;};EPS.SidePanel.prototype.getMinHeight=function(){return this.m_minHeight;};EPS.SidePanel.prototype.setMinHeight=function(newMinHeight){if(!this.m_regexHeightWidth.test(newMinHeight)){logger.logError("Parameter newMinHeight must match the regex /^(\d+((px)|%){1})$/ for the EPS.SidePanel.setMinHeight function.");return;}
this.m_minHeight=newMinHeight;if(this.m_sidePanelObj&&this.m_sidePanelObj.length){this.m_sidePanelObj.css({"min-height":this.m_minHeight});}
return this;};EPS.SidePanel.prototype.getOnExpandFunction=function(){return this.m_onExpandFunc;};EPS.SidePanel.prototype.setOnExpandFunction=function(func){if(typeof func!=="function"){logger.logError("Parameter func must be of type function for the EPS.SidePanel.setOnExpandFunction.");return;}
this.m_onExpandFunc=func;return this;};EPS.SidePanel.prototype.getOnCollapseFunction=function(){return this.m_onCollapseFunc;};EPS.SidePanel.prototype.setOnCollapseFunction=function(func){if(typeof func!=="function"){logger.logError("Parameter func must be of type function for the EPS.SidePanel.setOnCollapseFunction.");return;}
this.m_onCollapseFunc=func;return this;};EPS.SidePanel.prototype.renderSidePanel=function(){if(this.m_sidePanelContents){return;}
if(!this.m_containerElementId){logger.logError("Container element id for side panel has not been set to use in the EPS.SidePanel.renderSidePanel function.");return;}
this.m_parentContainer=$("#"+this.m_containerElementId);if(!this.m_parentContainer.length){logger.logError("Container element object for side panel not found to use in the EPS.SidePanel.renderSidePanel function.");return;}
if(!this.m_uniqueId){logger.logError("Unique id for side panel has not been set to use in the EPS.SidePanel.renderSidePanel function.");return;}
var uniqueId=this.m_uniqueId;var panelDivHTML="<div id='"+this.m_panelId+"' class='side-panel'><div id='closeButton"+uniqueId+"' class='sp-close-btn'>&nbsp;</div><div id='sidePanelContents"+uniqueId+"' class='sp-all-contents'>&nbsp;</div><div id='sidePanelExpandCollapse"+uniqueId+"' class='sp-expand-collapse hidden'><div id='sidePanelExpandCollapseIcon"+uniqueId+"'>&nbsp;</div></div></div>";this.m_parentContainer.html(panelDivHTML);this.m_sidePanelObj=$("#"+this.m_panelId);this.m_sidePanelContents=$("#sidePanelContents"+uniqueId);this.m_sidePanelBodyContents=$("#sidePanelContents"+uniqueId);this.m_closeButton=$("#closeButton"+uniqueId);this.setHeight(this.m_height);this.setWidth(this.m_width);if(this.m_minHeight){this.m_sidePanelObj.css("min-height",this.m_minHeight);}
this.m_closeButton.hide();};EPS.SidePanel.prototype.setContents=function(contents){if(!this.m_sidePanelBodyContents){this.renderSidePanel();}
if(typeof contents==="string"&&contents.length){this.m_sidePanelBodyContents.html(contents);}else{if(contents instanceof jQuery){this.m_sidePanelBodyContents.empty();this.m_sidePanelBodyContents.append(contents);}else{logger.logError("Parameter contents must be of type string or jQuery Object for the EPS.SidePanel.setContents function.");return;}}
this.m_scrollContainer=$("#sidePanelScrollContainer"+this.m_uniqueId);if(this.m_expandOption===this.expandOption.EXPAND_DOWN){if(!this.m_maxHeight){logger.logError("Max height must be set for use in EPS.SidePanel.setContents when an expand option is used.");return;}
this.setMaxHeight(this.m_maxHeight);this.m_expandOption.call(this);}else{this.m_sidePanelObj.css("height","auto");if(this.m_fullPanelScrollOn){if(!this.m_maxHeight){logger.logError("Max height must be set for use in EPS.SidePanel.setContents when full panel scrolling is turned on.");return;}
this.setMaxHeight(this.m_maxHeight);this.fullPanelScroll();}}};EPS.SidePanel.prototype.renderPreBuiltSidePanel=function(){if(this.m_sidePanelContents){return;}
if(!this.m_containerElementId){logger.logError("Container element id for side panel has not been set to use in the EPS.SidePanel.renderSidePanel function.");return;}
this.m_parentContainer=$("#"+this.m_containerElementId);if(!this.m_parentContainer.length){logger.logError("Container element object for side panel not found to use in the EPS.SidePanel.renderSidePanel function.");return;}
if(!this.m_uniqueId){logger.logError("Unique id for side panel has not been set to use in the EPS.SidePanel.renderSidePanel function.");return;}
this.m_usingUpdatedPanel=true;var uniqueId=this.m_uniqueId;var panelDivHTML="<div id='"+this.m_panelId+"' class='side-panel'><div id='sidePanelContents"+uniqueId+"'><div id='sidePanelHeader"+uniqueId+"' class='sp-header2'><div id='sidePanelActionBar"+uniqueId+"' class='sp-action-bar'><div id='sidePanelActions"+uniqueId+"' class='sp-actions'>&nbsp;</div><div id='cornerCloseButton"+uniqueId+"' class='sp-close-btn2'>&nbsp;</div></div><div id='sidePanelAlertBanner"+uniqueId+"' class='sp-alert-banner'>&nbsp;</div><div id='sidePanelHeaderText"+uniqueId+"' class='sp-header-text'>&nbsp;</div><div id='sidePanelSubtitle"+uniqueId+"' class='sp-subtitle secondary-text'>&nbsp;</div></div><div class='sp-separator2'>&nbsp;</div><div id='sidePanelBodyContents"+uniqueId+"' class='sp-body-contents'>&nbsp;</div></div><div id='sidePanelExpandCollapse"+uniqueId+"' class='sp-expand-collapse2 hidden'><div id='sidePanelExpandCollapseIcon"+uniqueId+"' class='sp-expand'>&nbsp;</div></div></div>";this.m_parentContainer.html(panelDivHTML);this.m_sidePanelObj=$("#"+this.m_panelId);this.m_sidePanelBodyContents=$("#sidePanelBodyContents"+uniqueId);this.m_sidePanelContents=$("#sidePanelContents"+uniqueId);this.m_sidePanelHeader=$("#sidePanelHeader"+uniqueId);this.m_cornerCloseButton=$("#cornerCloseButton"+uniqueId);this.m_headerTitleObj=$("#sidePanelHeaderText"+uniqueId);this.m_subtitleObj=$("#sidePanelSubtitle"+uniqueId);this.m_sidePanelActionsObj=$("#sidePanelActions"+uniqueId);this.m_sidePanelAlertBanner=$("#sidePanelAlertBanner"+uniqueId);this.setHeight(this.m_height);this.setWidth(this.m_width);if(this.m_minHeight){this.m_sidePanelObj.css("min-height",this.m_minHeight);}
this.m_cornerCloseButton.hide();this.m_subtitleObj.addClass("hidden");this.m_sidePanelAlertBanner.addClass("hidden");};EPS.SidePanel.prototype.setTitleText=function(titleString){if(!this.m_headerTitleObj){logger.logError("Side panel title object cannot be found.");return;}
this.m_headerTitleObj.text(titleString);};EPS.SidePanel.prototype.setSubtitleText=function(subtitleString){if(!this.m_subtitleObj){logger.logError("Side panel subtitle object cannot be found.");return;}
this.m_subtitleObj.text(subtitleString);this.m_subtitleObj.removeClass("hidden");};EPS.SidePanel.prototype.setSubtitleAsHTML=function(subtitleHTML){if(!this.m_subtitleObj){logger.logError("Side panel subtitle object cannot be found.");return;}
this.m_subtitleObj.html(subtitleHTML);this.m_subtitleObj.removeClass("hidden");};EPS.SidePanel.prototype.removeSubtitle=function(){if(!this.m_subtitleObj){logger.logError("Side panel subtitle object cannot be found.");return;}
this.m_subtitleObj.addClass("hidden");};EPS.SidePanel.prototype.setActionsAsHTML=function(actionHTML){if(!this.m_sidePanelActionsObj){logger.logError("Side panel action bar object cannot be found.");return;}
this.m_sidePanelActionsObj.html(actionHTML);};EPS.SidePanel.prototype.setAlertBannerAsHTML=function(bannerHTML){if(!this.m_sidePanelAlertBanner){logger.logError("Side panel alert banner object cannot be found.");return;}
this.m_sidePanelAlertBanner.html(bannerHTML);this.m_sidePanelAlertBanner.removeClass("hidden");this.m_sidePanelObj.addClass("sp-alert-banner-showing");};EPS.SidePanel.prototype.removeAlertBanner=function(){if(!this.m_sidePanelAlertBanner){logger.logError("Side panel alert banner object cannot be found.");return;}
this.m_sidePanelAlertBanner.addClass("hidden");this.m_sidePanelObj.removeClass("sp-alert-banner-showing");};EPS.SidePanel.prototype.showCornerCloseButton=function(){if(!this.m_cornerCloseButton){logger.logError("Corner close button is not defined");return;}
this.m_cornerCloseButton.removeAttr("style");};EPS.SidePanel.prototype.getCornerCloseFunction=function(){return this.m_cornerCloseFunction;};EPS.SidePanel.prototype.setCornerCloseFunction=function(closeFunction){if(closeFunction instanceof Function){this.m_cornerCloseFunction=closeFunction;}else{logger.logError("Corner close function must be of type 'Function'.");return;}};EPS.SidePanel.prototype.showHideExpandBar=function(){if(this.m_usingUpdatedPanel&&this.m_sidePanelObj[0].offsetHeight){var sidePanelBody=document.getElementById("sidePanelBodyContents"+this.m_uniqueId);var visibleSidePanelHeight=this.m_sidePanelObj[0].offsetHeight;var titleHeight=this.m_sidePanelHeader[0].offsetHeight;var visibleBodyHeight=0;if(titleHeight<visibleSidePanelHeight){visibleBodyHeight=visibleSidePanelHeight-titleHeight;}else{this.m_expCollapseBarObj.removeClass("hidden");}
if(visibleBodyHeight&&sidePanelBody.scrollHeight>visibleBodyHeight){this.m_expCollapseBarObj.removeClass("hidden");}else{if(visibleBodyHeight&&visibleBodyHeight>=sidePanelBody.scrollHeight){this.m_expCollapseBarObj.addClass("hidden");}}}};EPS.SidePanel.prototype.resizePanel=function(maxHeight){if(!this.m_regexHeightWidth.test(maxHeight)){logger.logError("Parameter maxHeight must match the regex /^(\d+((px)|%){1})$/ for the EPS.SidePanel.resizePanel function.");return;}
this.m_maxHeight=maxHeight;if(this.m_expandOption===this.expandOption.EXPAND_DOWN){this.setMaxHeight(this.m_maxHeight);this.showHideExpandBar();this.collapseSidePanel();}else{if(this.m_fullPanelScrollOn){this.setMaxHeight(this.m_maxHeight);this.fullPanelScroll();}}};EPS.SidePanel.prototype.fullPanelScroll=function(){if(!this.m_scrollContainer.length){logger.logError("Scroll container object for side panel not found for use in EPS.SidePanel.fullPanelScroll.");return;}
if(!this.m_maxHeight){logger.logError("Max height for side panel not set for use in EPS.SidePanel.fullPanelScroll.");return;}
if(this.m_scrollContainer.css("max-height")!=="none"){this.m_scrollContainer.css("max-height","none");}
var titleHeight=null;if(this.m_usingUpdatedPanel){var bodyContentHeight=this.m_sidePanelBodyContents[0].offsetHeight;titleHeight=this.m_sidePanelContents.height()-bodyContentHeight;}else{var contentHeight=this.m_sidePanelContents[0].offsetHeight;titleHeight=contentHeight-this.m_scrollContainer.height();}
this.m_sidePanelObj.css({height:"auto"});var scrollMaxHeight=(this.m_sidePanelObj.height()-titleHeight)+1;this.m_scrollContainer.css("max-height",scrollMaxHeight+"px");if(scrollMaxHeight===this.m_scrollContainer.height()){this.m_scrollContainer.addClass("sp-add-scroll");}else{this.m_scrollContainer.removeClass("sp-add-scroll");}};EPS.SidePanel.prototype.expandDownListeners=function(){if(this.m_sidePanelObj===null){return;}
var uniqueId=this.m_uniqueId;var self=this;var expCollapseBarId="#sidePanelExpandCollapse"+uniqueId;this.m_expCollapseIconObj=$("#sidePanelExpandCollapseIcon"+uniqueId);this.m_expCollapseBarObj=$(expCollapseBarId);var scrollContainer=null;var ppId="#"+this.m_panelId;this.m_sidePanelObj.off();if(!this.m_sidePanelObj.hasClass("sp-focusin")){this.showHideExpandBar();}
if(!this.m_usingUpdatedPanel){this.m_sidePanelObj.on("mouseenter",function(){if(!self.m_expCollapseBarObj.hasClass("hidden")){return;}
scrollContainer=$("#sidePanelScrollContainer"+uniqueId);if((this.scrollHeight>this.offsetHeight)||scrollContainer.hasClass("sp-add-scroll")){self.m_expCollapseIconObj.addClass("sp-expand").removeClass("sp-collapse");self.m_expCollapseBarObj.removeClass("hidden");}
if(self.m_mouseEnterFunc){self.m_mouseEnterFunc();}});this.m_sidePanelObj.on("mouseleave",function(){if(self.m_expCollapseIconObj.hasClass("sp-expand")){self.m_expCollapseBarObj.addClass("hidden");}
if(self.m_mouseLeaveFunc){self.m_mouseLeaveFunc();}});}
this.m_sidePanelObj.on("click",expCollapseBarId,function(event){self.expandCollapseSidePanel();});if(this.m_expCollapseIconObj.hasClass("sp-collapse")){this.expandSidePanel();}};EPS.SidePanel.prototype.expandCollapseSidePanel=function(){if(!this.m_sidePanelObj.length){return;}
if(this.m_expCollapseIconObj.hasClass("sp-expand")){this.expandSidePanel();}else{this.collapseSidePanel();}};EPS.SidePanel.prototype.expandSidePanel=function(){if(!this.m_sidePanelObj.hasClass("sp-focusin")){this.m_expCollapseBarObj.removeClass("hidden");this.m_parentContainer.css({position:"absolute"});this.m_sidePanelObj.addClass("sp-focusin");this.m_expCollapseIconObj.addClass("sp-collapse").removeClass("sp-expand");}
this.m_previousMinHeight=this.m_minHeight;var heightVal=parseInt(this.m_height,10);var minHeightVal=parseInt(this.m_minHeight,10);if(heightVal>minHeightVal){this.setMinHeight(this.m_height);}
this.m_scrollContainer.css("max-height","");var titleHeight=null;if(this.m_usingUpdatedPanel){var bodyContentHeight=this.m_sidePanelBodyContents[0].offsetHeight;titleHeight=this.m_sidePanelContents.height()-bodyContentHeight;}else{var contentHeight=this.m_sidePanelContents[0].offsetHeight;titleHeight=contentHeight-this.m_scrollContainer.height();}
this.m_sidePanelObj.css({height:"auto"});var scrollMaxHeight=(this.m_sidePanelObj.height()-titleHeight)+1;this.m_scrollContainer.css("max-height",scrollMaxHeight+"px");if(scrollMaxHeight===this.m_scrollContainer.height()){this.m_scrollContainer.addClass("sp-add-scroll");}
if(this.m_onExpandFunc){this.m_onExpandFunc();}};EPS.SidePanel.prototype.collapseSidePanel=function(){if(this.m_expCollapseIconObj.hasClass("sp-collapse")){this.m_parentContainer.css({position:"relative"});this.m_sidePanelObj.css("height",this.m_height);this.m_scrollContainer.css("max-height","none");this.m_scrollContainer.removeClass("sp-add-scroll");if(this.m_usingUpdatedPanel){this.m_expCollapseIconObj.removeClass("sp-collapse").addClass("sp-expand");}else{this.m_expCollapseIconObj.removeClass("sp-collapse");this.m_expCollapseBarObj.addClass("hidden");}
this.m_sidePanelObj.removeClass("sp-focusin");this.showHideExpandBar();this.setMinHeight(this.m_previousMinHeight);if(this.m_onCollapseFunc){this.m_onCollapseFunc();}}};EPS.SidePanel.prototype.expandOption={NONE:null,EXPAND_DOWN:EPS.SidePanel.prototype.expandDownListeners};EPS.SidePanel.prototype.showPanel=function(){this.m_sidePanelObj.show();};EPS.SidePanel.prototype.hidePanel=function(){this.m_sidePanelObj.hide();};EPS.SidePanel.prototype.showCloseButton=function(){if(!this.m_closeButton){logger.logError("Close button is not defined");return;}
this.m_closeButton.show();};EPS.SidePanel.prototype.getCloseFunction=function(){return this.m_closeFunction;};EPS.SidePanel.prototype.setCloseFunction=function(closeFunction){if(closeFunction instanceof Function){this.m_closeFunction=closeFunction;}};EPS.StandardTemplates={};EPS.StandardTemplates.CLINICAL_LINK=['<span>${ ((EVENT_CD_DISP) ? MP_Util.CreateClinNoteLink(PERSON_ID+".0",ENCNTR_ID+".0",EVENT_ID+".0",EVENT_CD_DISP,VIEWER_TYPE,PARENT_EVENT_ID+".0") : "--") }</span>'].join("");EPS.TableExtension=function(){return this;}
EPS.TableExtension.prototype.finalize=function(table){throw new Error("Error, finalize method not implemented in a base EPS.TableExtension class");};EPS.TableCellClickCallbackExtension=function(){this.callback=function(event,data){return;};return this;}
EPS.TableCellClickCallbackExtension.prototype=new EPS.TableExtension();EPS.TableCellClickCallbackExtension.prototype.constructor=EPS.TableExtension;EPS.TableCellClickCallbackExtension.prototype.setCellClickCallback=function(callback){if(typeof callback!=="function"){throw new Error("In EPS.TableCellCallbackExtension, attempted to setCallback() with non function type");}
this.callback=callback;return this;};EPS.TableCellClickCallbackExtension.prototype.finalize=function(table){var self=this;var namespace=table.getNamespace();var resultData=null;var columnId="";var data={};$("#"+namespace+"tableBody").on("mouseup",".table-cell",function(event){resultData=EPS.ComponentTableDataRetriever.getResultFromTable(table,this);columnId=EPS.ComponentTableDataRetriever.getColumnIdFromElement(table,this);data={COLUMN_ID:columnId,RESULT_DATA:resultData,SOURCE:"EPS.TableCellClickCallbackExtension:CELL_CLICK"};self.callback(event,data);});};EPS.TableColumn=function(){this.columnDisplay="&nbsp;";this.columnId="";this.customClass="";this.primarySortField="";this.secondarySortFields=[];this.isSortable=false;this.sortDirection=EPS.TableColumn.SORT.NONE;this.template=EPS.TemplateBuilder.buildTemplate("<span>[Template Not Specified]</span>");this.width=null;this.defaultSort=EPS.TableColumn.SORT.ASCENDING;}
EPS.TableColumn.prototype.getColumnDisplay=function(){return this.columnDisplay;};EPS.TableColumn.prototype.setColumnDisplay=function(columnDisplay){if(typeof columnDisplay!=="string"){throw new Error("Called setColumnDisplay on EPS.TableColumn with non string type for columnDisplay parameter");}
this.columnDisplay=columnDisplay;return this;};EPS.TableColumn.prototype.getColumnId=function(){return this.columnId;};EPS.TableColumn.prototype.setColumnId=function(columnId){if(typeof columnId!=="string"){throw new Error("Called setColumnId on EPS.TableColumn with non string type for columnId parameter");}
this.columnId=columnId;return this;};EPS.TableColumn.prototype.getCustomClass=function(){return this.customClass;};EPS.TableColumn.prototype.setCustomClass=function(customClass){if(typeof customClass!=="string"){throw new Error("Called setCustomClass on EPS.TableColumn with non string type for customClass parameter");}
this.customClass=customClass;return this;};EPS.TableColumn.prototype.getDefaultSort=function(){return this.defaultSort;};EPS.TableColumn.prototype.setDefaultSort=function(defaultSort){if(EPS.TableColumn.isValidSortDirection(defaultSort)){this.defaultSort=defaultSort;}
return this;};EPS.TableColumn.prototype.getPrimarySortField=function(){return this.primarySortField;};EPS.TableColumn.prototype.setPrimarySortField=function(primarySortField){if(typeof primarySortField!=="string"){throw new Error("Invalid data field parameter for column, must be a string");}
this.primarySortField=primarySortField;return this;};EPS.TableColumn.prototype.addSecondarySortField=function(field,direction){if(typeof direction!=="number"){throw new Error("Called addSecondarySortField on EPS.TableColumn with non number type for direction parameter");}
if(!EPS.TableColumn.isValidSortDirection(direction)){throw new Error("Called addSecondarySortField on EPS.TableColumn with invalid direction. Please use EPS.TableColumn.SORT.ASCENDING or EPS.TableColumn.SORT.DESCENDING");}
if(typeof field!=="string"){throw new Error("Called addSecondarySortField on EPS.TableColumn with non string type for field parameter.");}
this.secondarySortFields.push({FIELD:field,DIRECTION:direction});};EPS.TableColumn.prototype.getSecondarySortFields=function(){return this.secondarySortFields;};EPS.TableColumn.prototype.getIsSortable=function(){return this.isSortable;};EPS.TableColumn.prototype.setIsSortable=function(isSortable){if(typeof isSortable!=="boolean"){throw new Error("Called setIsSortable on EPS.TableColumn with non boolean type for isSortable parameter");}
this.isSortable=isSortable;return this;};EPS.TableColumn.prototype.setColumnSortDirection=function(sortDirection){if(typeof sortDirection!=="number"){throw new Error("Called setColumnSortDirection on EPS.TableColumn with non number type for sortDirection parameter");}
if(sortDirection<-1||sortDirection>1){throw new Error("Called setColumnSortDirection on EPS.TableColumn with invalid sortDirection: "+sortDirection+" the value must be 0, -1, or 1. It is recommended that you use EPS.TableColumn.SORT.NONE, EPS.TableColumn.SORT.ASCENDING, or EPS.TableColumn.SORT.DESCENDING");}
this.sortDirection=sortDirection;return this;};EPS.TableColumn.prototype.getColumnSortDirection=function(){return this.sortDirection;};EPS.TableColumn.prototype.getRenderTemplate=function(){return this.template;};EPS.TableColumn.prototype.setRenderTemplate=function(template){this.template=EPS.TemplateBuilder.buildTemplate(template);return this;};EPS.TableColumn.prototype.getWidth=function(){return this.width;};EPS.TableColumn.prototype.setWidth=function(width){if(typeof width!=="number"){throw new Error("Called setWidth on EPS.TableColumn with non number type for width parameter");}
if(width<0){throw new Error("Cannot call setWidth on EPS.TableColumn with a negative number");}
this.width=width;return this;};EPS.TableColumn.isValidSortDirection=function(sortDirection){if(typeof sortDirection!=="number"){throw new Error("Called isValidSortDirection on EPS.TableColumn with non number type for sortDirection parameter");}
return(Math.abs(sortDirection)===1);};EPS.TableColumn.SORT={ASCENDING:-1,DESCENDING:1,NONE:0};EPS.TableGroup=function(){this.canCollapse=true;this.display="";this.expanded=true;this.groupId="";this.key="";this.rows=[];this.rowMap={};this.showCount=false;this.groupValue="";this.hideHeader=false;}
EPS.TableGroup.prototype.bindData=function(data){for(var i=0;i<data.length;i++){var tableRow=new EPS.TableRow().setResultData(data[i]).setId("row"+i);this.rows.push(tableRow);this.rowMap[tableRow.getId()]=tableRow;}
return this;};EPS.TableGroup.prototype.clearData=function(){this.rows=[];this.rowMap={};};EPS.TableGroup.prototype.getCanCollapse=function(){return this.canCollapse;};EPS.TableGroup.prototype.setCanCollapse=function(canCollapse){if(typeof canCollapse!=="boolean"){throw new Error("Called setCanCollapse on EPS.TableGroup with non boolean type for parameter canCollapse");}
this.canCollapse=canCollapse;return this;};EPS.TableGroup.prototype.getDisplay=function(){return this.display;};EPS.TableGroup.prototype.setDisplay=function(display){if(typeof display!=="string"){throw new Error("Called setDisplay on EPS.TableGroup with non string type for parameter display");}
this.display=display;return this;};EPS.TableGroup.prototype.isExpanded=function(){return this.expanded;};EPS.TableGroup.prototype.setIsExpanded=function(expanded){if(typeof expanded!=="boolean"){throw new Error("Called setIsExpanded on EPS.TableGroup with non boolean type for isExpanded parameter");}
this.expanded=expanded;return this;};EPS.TableGroup.prototype.getGroupId=function(){return this.groupId;};EPS.TableGroup.prototype.setGroupId=function(groupId){if(typeof groupId!=="string"&&typeof groupId!=="number"){throw new Error("Called setGroupId on EPS.TableGroup with non string type for groupId parameter");}
this.groupId=groupId;return this;};EPS.TableGroup.prototype.getKey=function(){return this.key;};EPS.TableGroup.prototype.setKey=function(key){if(typeof key!=="string"&&typeof key!=="number"){throw new Error("Called setKey on EPS.TableGroup with non string/number type for parameter key");}
this.key=key;return this;};EPS.TableGroup.prototype.addRow=function(row){if(!EPS.TableRow.prototype.isPrototypeOf(row)){throw new Error("Called addRow on EPS.TableGroup with non EPS.TableRow type for row parameter");}
this.rows.push(row);this.rowMap[row.getId()]=row;return this;};EPS.TableGroup.prototype.getRows=function(){return this.rows;};EPS.TableGroup.prototype.getRowById=function(rowId){if(!this.hasRow(rowId)){throw new Error("In getRowById on EPS.TableGroup, EPS.TableRow with id: "+rowId+" does not exist");}
return this.rowMap[rowId];};EPS.TableGroup.prototype.hasRow=function(rowId){return((typeof this.rowMap[rowId]!=="undefined")&&this.rowMap[rowId]!==null);};EPS.TableGroup.prototype.setRows=function(rows){if(!(rows instanceof Array)){throw new Error("Called setRows on EPS.TableGroup with non Array type for rows parameter");}
this.rows=rows;return this;};EPS.TableGroup.prototype.getShowCount=function(){return this.showCount;};EPS.TableGroup.prototype.setShowCount=function(showCount){if(typeof showCount!=="boolean"){throw new Error("Called setShowCount on EPS.TableGroup with non boolean type for showCount parameter");}
this.showCount=showCount;return this;};EPS.TableGroup.prototype.getValue=function(){return this.groupValue;};EPS.TableGroup.prototype.setValue=function(groupValue){if(typeof groupValue!=="string"&&typeof groupValue!=="number"){throw new Error("Called setValue on EPS.TableGroup with non string type for parameter value");}
this.groupValue=groupValue;return this;};EPS.TableGroup.prototype.getHideHeader=function(){return this.hideHeader;};EPS.TableGroup.prototype.setHideHeader=function(hideHeader){if(typeof hideHeader!=="boolean"){throw new Error("Called setShowHeader on EPS.TableGroup with non-boolean type for showHeader parameter value");}
this.hideHeader=hideHeader;return this;};EPS.TableGroup.parseGroupId=function(elementId){return elementId.split(":")[1];};EPS.TableGroupToggleCallbackExtension=function(){this.callback=function(event,data){return;};return this;}
EPS.TableGroupToggleCallbackExtension.prototype=new EPS.TableExtension();EPS.TableGroupToggleCallbackExtension.prototype.constructor=EPS.TableExtension;EPS.TableGroupToggleCallbackExtension.prototype.setGroupToggleCallback=function(callback){if(typeof callback!=="function"){throw new Error("Called setGroupToggleCallback on EPS.TableGroupToggleCallbackExtension with non function type for callback parameter");}
this.callback=callback;return this;};EPS.TableGroupToggleCallbackExtension.prototype.finalize=function(table){var self=this;var namespace=table.getNamespace();var data={};$("#"+namespace+"tableBody").on("click",".sub-sec-hd",function(event){var group=table.getGroupById(EPS.TableGroup.parseGroupId($(this).attr("id")));data={GROUP_DATA:{KEY:group.getKey(),VALUE:group.getValue(),EXPANDED:group.isExpanded(),GROUP_ID:group.getGroupId()},SOURCE:"EPS.TableGroupToggleCallbackExtension:GROUP_CLICK"};self.callback(event,data);});};EPS.HoverExtension=function(){this.hoverClass="mpage-tooltip-hover";this.onHover=function(){return;};this.onLeave=function(){return;};this.target="";this.tooltip=new EPS.MPageTooltip().setShowDelay(0);return this;}
EPS.HoverExtension.prototype=new EPS.TableExtension();EPS.HoverExtension.prototype.constructor=EPS.TableExtension;EPS.HoverExtension.prototype.getHoverClass=function(){return this.hoverClass;};EPS.HoverExtension.prototype.setHoverClass=function(hoverClass){if(typeof hoverClass!=="string"){throw new Error("Called setHoverClass on EPS.HoverExtension with non string type for hoverClass parameter");}
this.hoverClass=hoverClass;return this;};EPS.HoverExtension.prototype.setOnHoverCallback=function(onHover){if(typeof onHover!=="function"){throw new Error("Called setOnHoverCallback on EPS.HoverExtension with non function type for onHover parameter");}
this.onHover=onHover;return this;};EPS.HoverExtension.prototype.setOnLeaveCallback=function(onLeave){if(typeof onLeave!=="function"){throw new Error("Called setOnLeaveCallback on EPS.HoverExtension with non function type for onLeave parameter");}
this.onLeave=onLeave;return this;};EPS.HoverExtension.prototype.getTarget=function(){return this.target;};EPS.HoverExtension.prototype.setTarget=function(target){if(typeof target!=="string"){throw new Error("Called setTarget on EPS.HoverExtension with non string type for target parameter");}
this.target=target;return this;};EPS.HoverExtension.prototype.getTooltip=function(){return this.tooltip;};EPS.HoverExtension.prototype.setTooltip=function(tooltip){if(!(EPS.MPageTooltip.prototype.isPrototypeOf(tooltip))){throw new Error("Called setTooltip on EPS.HoverExtension with non EPS.MPageTooltip type for tooltip parameter");}
this.tooltip=tooltip;return this;};EPS.HoverExtension.prototype.finalize=function(table){var thiz=this;var tableBodyTag="#"+table.getNamespace()+"tableBody";var elementMap={};$(tableBodyTag).on("mouseenter",this.getTarget(),function(event){var anchor=this;var anchorId=$(this).attr("id");if(thiz.getHoverClass()!==""){$(this).addClass(thiz.getHoverClass());}
if(!elementMap[anchorId]){elementMap[anchorId]={};}
thiz.onHover(event);elementMap[anchorId].TIMEOUT=setTimeout(function(){thiz.showHover(event,table,anchor);},500);});$(tableBodyTag).on("mouseleave",this.getTarget(),function(event){$(this).removeClass("mpage-tooltip-hover");clearTimeout(elementMap[$(this).attr("id")].TIMEOUT);thiz.onLeave(event);});};EPS.HoverExtension.prototype.showHover=function(event,table,anchor){throw new Error("showHover has not been overwritten for a EPS.HoverExtension base class");};EPS.TableRowHoverExtension=function(){this.setTarget("dl.result-info");this.hoverRenderer=null;return this;}
EPS.TableRowHoverExtension.prototype=new EPS.HoverExtension();EPS.TableRowHoverExtension.prototype.constructor=EPS.HoverExtension;EPS.TableRowHoverExtension.prototype.getHoverRenderer=function(){return this.hoverRenderer;};EPS.TableRowHoverExtension.prototype.setHoverRenderer=function(renderer){this.hoverRenderer=EPS.HoverRenderFactory.getHoverRenderer(renderer);return this;};EPS.TableRowHoverExtension.prototype.showHover=function(event,table,anchor){if(!this.hoverRenderer){return;}
var data={};data.RESULT_DATA=EPS.ComponentTableDataRetriever.getResultFromTable(table,anchor);data.SOURCE="EPS.TableRowHoverExtension:ROW_HOVER";var content=this.hoverRenderer.render(data);if(!content){return;}
var tooltip=this.getTooltip();tooltip.setX(event.pageX).setY(event.pageY).setAnchor(anchor).setContent(this.hoverRenderer.render(data));tooltip.show();};EPS.TableCellHoverExtension=function(){this.setTarget("dd.table-cell");this.templateMap={};return this;}
EPS.TableCellHoverExtension.prototype=new EPS.HoverExtension();EPS.TableCellHoverExtension.prototype.constructor=EPS.HoverExtension;EPS.TableCellHoverExtension.prototype.addHoverForColumn=function(column,renderer){if(!EPS.TableColumn.prototype.isPrototypeOf(column)){throw new Error("Called addTemplateForColumn on EPS.TableCellHoverExtension with non EPS.TableColumn type for column parameter");}
this.templateMap[column.getColumnId()]=EPS.HoverRenderFactory.getHoverRenderer(renderer);};EPS.TableCellHoverExtension.prototype.showHover=function(event,table,anchor){var data={};var columnId=EPS.ComponentTableDataRetriever.getColumnIdFromElement(table,anchor);var hoverRenderer=this.templateMap[columnId];if(!hoverRenderer){return;}
data.RESULT_DATA=EPS.ComponentTableDataRetriever.getResultFromTable(table,anchor);data.COLUMN_ID=columnId;data.SOURCE="EPS.TableCellHoverExtension:CELL_HOVER";data.EVENT=event;var content=hoverRenderer.render(data);if(!content){return;}
var tooltip=this.getTooltip();tooltip.setX(event.pageX).setY(event.pageY).setAnchor(anchor).setContent(content);tooltip.show();};EPS.HoverRenderFactory=function(){}
EPS.HoverRenderFactory.getHoverRenderer=function(renderObject){var renderer=null;if(typeof renderObject==="string"){renderer=new EPS.StringTemplateRenderer();}else{if(typeof renderObject==="function"){renderer=new EPS.FunctionRenderer();}else{throw new Error("Called getHoverRenderer on EPS.HoverRenderFactory with invalid type for renderObject, use string or function");}}
renderer.init(renderObject);return renderer;};EPS.HoverRenderer=function(){}
EPS.HoverRenderer.prototype.init=function(renderObject){throw new Error("EPS.HoverRenderer init method not implemented");};EPS.HoverRenderer.prototype.render=function(data){throw new Error("EPS.HoverRenderer render method not implemented");};EPS.StringTemplateRenderer=function(){this.template=null;}
EPS.StringTemplateRenderer.prototype=new EPS.HoverRenderer();EPS.StringTemplateRenderer.prototype.constructor=EPS.HoverRenderer;EPS.StringTemplateRenderer.prototype.getTemplate=function(){return this.template;};EPS.StringTemplateRenderer.prototype.setTemplate=function(template){this.template=template;return this;};EPS.StringTemplateRenderer.prototype.init=function(renderObject){return this.setTemplate(EPS.TemplateBuilder.buildTemplate(renderObject));};EPS.StringTemplateRenderer.prototype.render=function(data){return this.template.render(data);};EPS.FunctionRenderer=function(){this.renderFunction=function(data){return"";};}
EPS.FunctionRenderer.prototype=new EPS.HoverRenderer();EPS.FunctionRenderer.prototype.constructor=EPS.HoverRenderer;EPS.FunctionRenderer.prototype.getRenderFunction=function(){return this.renderFunction;};EPS.FunctionRenderer.prototype.setRenderFunction=function(renderFunction){if(typeof renderFunction!=="function"){throw new Error("Called setRenderFunction on EPS.FunctionRenderer with non function type for renderFunction parameter");}
this.renderFunction=renderFunction;return this;};EPS.FunctionRenderer.prototype.init=function(renderObject){return this.setRenderFunction(renderObject);};EPS.FunctionRenderer.prototype.render=function(data){return this.renderFunction(data);};EPS.TableRow=function(){this.rowId="";this.tableCells=[];this.resultData=null;return this;}
EPS.TableRow.prototype.setResultData=function(resultData){if(typeof resultData!=="object"){throw new Error("Called setResultData on EPS.TableRow with non object type for the resultData parameter");}
this.resultData=resultData;return this;};EPS.TableRow.prototype.getResultData=function(){return this.resultData;};EPS.TableRow.prototype.getId=function(){return this.rowId;};EPS.TableRow.prototype.setId=function(id){this.rowId=id;return this;};EPS.TableRow.prototype.getTableCells=function(){return this.tableCells;};EPS.TableRow.prototype.setTableCells=function(tableCells){if(!tableCells instanceof Array){throw new Error("Called setTableCells on EPS.TableRow with type other than Array");}
this.tableCells=tableCells;return this;};EPS.TableRow.prototype.addTableCell=function(columnId,tableCell){if(typeof columnId!=="string"){throw new Error("Called addTableCell on EPS.TableRow and passed non string type for columnId parameter");}
if(!EPS.TableCell.prototype.isPrototypeOf(tableCell)){throw new Error("Called addTableCell on EPS.TableRow and passed non EPS.TableCell type for tableCell parameter");}
this.tableCells[columnId]=tableCell;};EPS.TableRow.prototype.getTableCellInColumn=function(columnId){if(typeof columnId!=="string"){throw new Error("Called getTableCellInColumn on EPS.TableRow and passed non string type for columnId parameter");}
if(typeof this.tableCells[columnId]==="undefined"||this.tableCells[columnId]===null){throw new Error("In method getTableCellInColumn, the columnId: "+columnId+" returned undefined or null");}
return this.tableCells[columnId];};

// Lines, Tubes, Drains
MPage.namespace("phsa_cd.intraopltd");

phsa_cd.intraopltd = function () {};
phsa_cd.intraopltd.prototype = new MPage.Component();
phsa_cd.intraopltd.prototype.constructor = MPage.Component;
phsa_cd.intraopltd.prototype.base = MPage.Component.prototype;
phsa_cd.intraopltd.prototype.name = "phsa_cd.intraopltd";
phsa_cd.intraopltd.prototype.cclProgram = "1PHSA_CD_INTRAOP_LTD";
phsa_cd.intraopltd.prototype.cclParams = [];
phsa_cd.intraopltd.prototype.cclDataType = "JSON";

phsa_cd.intraopltd.prototype.init = function () {
    var component = this;
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
    component.cclParams.push(this.getProperty("encounterId"));
};

phsa_cd.intraopltd.prototype.render = function () {
    var component = this;
    var target = component.getTarget();
    var rowHeadingArray = [
        "<td class='ltd-label-column ltd-row0'>Catheters (<span id='cathNum'></span>)</td>"
        , "<td class='ltd-label-column'>Device Description:</td>"
        , "<td class='ltd-label-column'>Balloon Inflation Amount (mL):</td>"
        , "<td class='ltd-label-column'>Location:</td>"
        , "<td class='ltd-label-column'>Secured With:</td>"
        , "<td class='ltd-label-column'>Inserted By:</td>"
        , "<td class='ltd-label-column'>In situ:</td>"
        , "<td class='ltd-label-column'>Removed By:</td>"
        , "<td class='ltd-label-column'>In/Out Catherization:</td>"
        , "<td class='ltd-label-column'>Removed:</td>"
		, "<td class='ltd-label-column ltd-row0'>Drains (<span id='cdtNum'></span>)</td>"
        , "<td class='ltd-label-column'>Device Description:</td>"
        , "<td class='ltd-label-column'>Drain Number:</td>"
        , "<td class='ltd-label-column'>Location:</td>"
        , "<td class='ltd-label-column'>Location Detail:</td>"
        , "<td class='ltd-label-column'>Balloon Inflation Amount (mL):</td>"
        , "<td class='ltd-label-column'>Secured:</td>"
        , "<td class='ltd-label-column'>Secured With:</td>"
        , "<td class='ltd-label-column'>Drainiage System:</td>"
        , "<td class='ltd-label-column'>Removed:</td>"
	];

    // Inner functions
    component.writeHeaderColumn = function (iterationNumber) {
        return rowHeadingArray[iterationNumber];
    };

    var labData = component.data.LTD_DOCUMENTS;
    var entryData;
    var targetHTML = [];
    var maxCols = 0,
        cathCols = 0,
        cdtCols = 0,
        cols=0;
    var titleText = "";
    targetHTML.push("<div class='ltd-container'>");
    if (labData.ENTRIES_CNT === 0) {
        targetHTML.push("<span class='ltd-mpage-no-results'>No results found</span>");
    }
    else {
        targetHTML.push("<table class='ltd-box'>");
        for (var rows = 0; rows < rowHeadingArray.length; rows++) {
            targetHTML.push("<tr class='ltd-tr'>");
            targetHTML.push(component.writeHeaderColumn(rows));
            for (var entries = 0; entries < labData.ENTRIES_CNT; entries++) {
                entryData = labData.ENTRIES[entries];
                cathCols = entryData.CATHETER_CNT;
                cdtCols = entryData.DRAINS_TUBES_CNT;
                maxCols = Math.max(cathCols, cdtCols);
                switch (rows) {
                    case 0: {
                        for (cols = 0; cols < maxCols; cols++) {
                            targetHTML.push("<td class='ltd-data-column ltd-row0'>Entry ", cols + 1, ":</td>");
                        }
                        break;
                    }
                    case 1: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cathCols) && entryData.CATHETERS[cols].DEVICE_DESCRIPTION.length > 0) ? entryData.CATHETERS[cols].DEVICE_DESCRIPTION : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 2: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cathCols) && entryData.CATHETERS[cols].BALLOON_INFLATION_AMT.length > 0) ? entryData.CATHETERS[cols].BALLOON_INFLATION_AMT : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 3: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cathCols) && entryData.CATHETERS[cols].LOCATION.length > 0) ? entryData.CATHETERS[cols].LOCATION : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 4: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cathCols) && entryData.CATHETERS[cols].SECURED_DEVICE.length > 0) ? entryData.CATHETERS[cols].SECURED_DEVICE : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 5: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cathCols) && entryData.CATHETERS[cols].INSERTED.length > 0) ? entryData.CATHETERS[cols].INSERTED : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 6: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cathCols) && entryData.CATHETERS[cols].PRESENT_ON_ARRIVAL.length > 0) ? entryData.CATHETERS[cols].PRESENT_ON_ARRIVAL : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 7: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cathCols) && entryData.CATHETERS[cols].DC_BY.length > 0) ? entryData.CATHETERS[cols].DC_BY : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 8: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cathCols) && entryData.CATHETERS[cols].IN_OUT.length > 0) ? entryData.CATHETERS[cols].IN_OUT : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 9: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cathCols) && entryData.CATHETERS[cols].DC_AT_END_OF_CASE.length > 0) ? entryData.CATHETERS[cols].DC_AT_END_OF_CASE : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 10: {
                        for (cols = 0; cols < maxCols; cols++) {
                            targetHTML.push("<td class='ltd-data-column ltd-row0'></td>");
                        }
                        break;
                    }
                    case 11: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cdtCols) && entryData.DRAINS_TUBES[cols].DEVICE_DESCRIPTION.length > 0) ? entryData.DRAINS_TUBES[cols].DEVICE_DESCRIPTION : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 12: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cdtCols) && entryData.DRAINS_TUBES[cols].DRAIN_NUMBER.length > 0) ? entryData.DRAINS_TUBES[cols].DRAIN_NUMBER : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 13: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cdtCols) && entryData.DRAINS_TUBES[cols].LOCATION.length > 0) ? entryData.DRAINS_TUBES[cols].LOCATION : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 14: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cdtCols) && entryData.DRAINS_TUBES[cols].LOCATION_DETAIL.length > 0) ? entryData.DRAINS_TUBES[cols].LOCATION_DETAIL : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 15: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cdtCols) && entryData.DRAINS_TUBES[cols].BALLOON_INFLATION_AMT.length > 0) ? entryData.DRAINS_TUBES[cols].BALLOON_INFLATION_AMT : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 16: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cdtCols) && entryData.DRAINS_TUBES[cols].SECURED.length > 0) ? entryData.DRAINS_TUBES[cols].SECURED : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 17: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cdtCols) && entryData.DRAINS_TUBES[cols].SECURED_WITH.length > 0) ? entryData.DRAINS_TUBES[cols].SECURED_WITH : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 18: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cdtCols) && entryData.DRAINS_TUBES[cols].DRAINAGE_SYSTEM.length > 0) ? entryData.DRAINS_TUBES[cols].DRAINAGE_SYSTEM : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                    case 19: {
                        for (cols = 0; cols < maxCols; cols++) {
                            titleText = ((cols < cdtCols) && entryData.DRAINS_TUBES[cols].DC_AT_END_OF_CASE.length > 0) ? entryData.DRAINS_TUBES[cols].DC_AT_END_OF_CASE : "--";
                            targetHTML.push("<td class='ltd-data-column' title='", titleText, "'>", titleText, "</td>");
                        }
                        break;
                    }
                } //switch on row#
            } //for each entry (Periop Record)
            targetHTML.push("</tr>");
        } //for each row
        targetHTML.push("</table>");
    } // if we have data
    targetHTML.push("</div>");
    target.innerHTML = targetHTML.join("");

	// Update Catheter and Drain SubHeading counts
	$("#cathNum").html(cathCols);
	$("#cdtNum").html(cdtCols);
};
// Pre-Anesthesia Note
MPage.namespace("phsa_cd.proc_info");

phsa_cd.proc_info = function () {};
phsa_cd.proc_info.prototype = new MPage.Component();
phsa_cd.proc_info.prototype.constructor = MPage.Component;
phsa_cd.proc_info.prototype.base = MPage.Component.prototype;
phsa_cd.proc_info.prototype.name = "phsa_cd.proc_info";
phsa_cd.proc_info.prototype.cclProgram = "1phsa_cd_get_cases_procs";
phsa_cd.proc_info.prototype.cclParams = [];
phsa_cd.proc_info.prototype.cclDataType = "JSON";

phsa_cd.proc_info.prototype.init = function () {
    var component = this;
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
    component.cclParams.push(this.getProperty("encounterId"));
    component.cclParams.push(this.getProperty("userId"));
    component.cclParams.push(this.getProperty("positionCd"));
    component.cclParams.push(1); // json flag
};

phsa_cd.proc_info.prototype.render = function () {
    var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();

    var tempData = component.data.CASES_REC.PROCEDURE;

    var targetHTML = [];
    var dataList = [];

    targetHTML.push("<div class='subSections'>");

    var procedureData;
    var primaryData = [];
    var secondaryData = [];
    var secondaryCnt = 0;

    if (tempData.length > 0) {
        primaryData.push("<table class='primary_table'>");
        secondaryData.push("<table class='secondary_table'>");
        for (var i = 0; i < tempData.length; i++) {
            procedureData = tempData[i];
            if (procedureData.PRIMARY_IND === 1) {
                primaryData.push(
                    "<tr><td class='ltd-label-column'>Primary Procedure:</td><td>", procedureData.NAME, "</td></tr>"
                    , "<tr><td class='ltd-label-column'>Consent Procedure Description:</td><td>", procedureData.EVENT_TEXT, "</td></tr>"
                    , "<tr><td class='ltd-label-column'>Primary Surgeon:</td><td>", procedureData.PRIM_SURGEON_NAME_FULL, "</td></tr>"
                );
				if (typeof procedureData.SCHEDULED_PROCEDURE !== "undefined" && procedureData.SCHEDULED_PROCEDURE.length > 0) {
					primaryData.push("<tr><td class='ltd-label-column'>Scheduled Procedure:</td><td>", procedureData.SCHEDULED_PROCEDURE, "</td></tr>");
				}
				else {
                    primaryData.push("<tr><td class='ltd-label-column'>Procedure Start Date:</td><td>", procedureData.EVENT_DT_TM, "</td></tr>");
				}
            } // if
            else if (procedureData.PRIMARY_IND === 0) {
                secondaryCnt++;
                secondaryData.push(
                    "<tr><td class='ltd-label-column'>Secondary Procedure:</td><td>", procedureData.NAME, "</td></tr>"
                    , "<tr><td class='ltd-label-column'>Consent Procedure Description:</td><td>", procedureData.EVENT_TEXT, "</td></tr>"
                    , "<tr><td class='ltd-label-column'>Primary Surgeon:</td><td>", procedureData.PRIM_SURGEON_NAME_FULL, "</td></tr>"
                );
				if (typeof procedureData.SCHEDULED_PROCEDURE !== "undefined" && procedureData.SCHEDULED_PROCEDURE.length > 0) {
					secondaryData.push("<tr><td class='ltd-label-column'>Scheduled Procedure:</td><td>", procedureData.SCHEDULED_PROCEDURE, "</td></tr>");
				}
				else {
                    secondaryData.push("<tr><td class='ltd-label-column'>Procedure Start Date:</td><td>", procedureData.EVENT_DT_TM, "</td></tr>");
				}
                secondaryData.push("<tr><td class='ltd-label-column'>&nbsp;</td><td>&nbsp;</td></tr>");
            } // else
        } // for
        primaryData.push("</table>");
        secondaryData.push("</table>");

        dataList.push({
            title: "Primary Procedure",
            subTitle: "",
            content: primaryData.join(""),
            isExpand: true
        });
        dataList.push({
            title: "Secondary Procedure(s)",
            subTitle: "(" + secondaryCnt + ")",
            content: secondaryData.join(""),
            isExpand: true
        });

    } // if
    else {
        targetHTML.push("<span class='ltd-mpage-no-results'>No results found</span>");
    }
    targetHTML.push("</div>");
    target.innerHTML = targetHTML.join("");
    $("#" + compId + " .subSections").cernerSubSection(dataList);
};

/*Blood Product Availability Component. */
MPage.namespace("phsa_cd.blood_product_availability");

phsa_cd.blood_product_availability = function(){};
phsa_cd.blood_product_availability.prototype = new MPage.Component();
phsa_cd.blood_product_availability.prototype.constructor = MPage.Component;
phsa_cd.blood_product_availability.prototype.base = MPage.Component.prototype;
phsa_cd.blood_product_availability.prototype.name = "phsa_cd.blood_product_availability";
phsa_cd.blood_product_availability.prototype.cclProgram = "1phsa_cd_blood_product_avail";


phsa_cd.blood_product_availability.prototype.init = function(options) {
	//code to perform before immediately rendering (usually updating params is needed)
	var component = this;
	//clear cclParams in case of refresh
	component.cclParams = [];
	component.cclParams.push("MINE");
	//CAN USE ANY OR ALL OF THE FOLLOWING IN ORDER AS NEEDED:
	component.cclParams.push(this.getProperty("personId"));
	var display_keys = [];
	for(var i = 1;i<=100;i++){
		display_keys.push("UNITNUMBER"+i);
		display_keys.push("UNITDIVISION"+i);
		display_keys.push("TRANSFUSIONSTATUSUNIT"+i);
		display_keys.push("BLOODCOMPONENTTYPE"+i);
	}
	component.cclParams.push(""+display_keys+"");
};

phsa_cd.blood_product_availability.prototype.render = function() {
	var component = this;
	var compId = component.getComponentUid();
	var target = component.getTarget();
	var targetHTML = [];
	var recordData = component.data.BLOOD_PRODUCT;	
	
	targetHTML.push("<div class='phsa_cd_transfusion_info_div'><div class='phsa_cd_group_screen_div'><div class = 'phsa_cd_group_screen_div_header'>Group and Screen Status</div><span class = 'phsa_cd_group_screen_div_hdr'>Group And Screen Expiry (at 2359 hours):</span><span class = 'phsa_cd_group_screen_val'>",((recordData.GROUP_SCREEN_EXPIRY.length) > 0)?recordData.GROUP_SCREEN_EXPIRY:"No current specimen available.","</span>");
	targetHTML.push("<div class = 'phsa_cd_group_screen_preadmit_div'><span class = 'phsa_cd_group_screen_div_hdr'>Pre-Surgical Group And Screen Expiry (at 2359 hours):</span><span class = 'phsa_cd_group_screen_val'>",((recordData.GROUP_SCREEN_PREADMIT.length) > 0)?recordData.GROUP_SCREEN_PREADMIT:"No current specimen available.","</span></div></div>");
	//place holder div for subsections.
	targetHTML.push("<div class='phsa_cd_blood_product_div'><div class = 'phsa_cd_blood_product_div_header'>Blood Product Availability</div><div class='phsa_cd_blood_product_subsections'></div></div>");
	targetHTML.push("<div class='phsa_cd_transfusion_reaction_div'><div class = 'phsa_cd_transfusion_reaction_div_header'>Transfusion Reaction History</div><div class = 'theTable' id = 'phsa_cd_trans_reaction'></div></div></div>");	
	target.innerHTML = targetHTML.join("");
	var allocated_Length = recordData.ALLOCATED.length;
	var issued_Length = recordData.ISSUED.length;
	var previous_Length = recordData.PAST_THREE_MONTHS.length;
	//create subsections.
	$("#"+compId+" .phsa_cd_blood_product_subsections").cernerSubSection([
		{title:"Allocated", subTitle:"("+allocated_Length+")", content:"<div class = 'theTable' id = 'phsa_cd_allocated'></div>", isExpand:false},
		{title:"Issued", subTitle:"("+issued_Length+")", content:"<div class = 'theTable' id = 'phsa_cd_issued'></div>", isExpand:false},
		{title:"Presumed transfused (Issued,Final) within last 90 days", subTitle:"("+previous_Length+")", content:"<div class = 'theTable' id = 'phsa_cd_previous_three_months'></div>", isExpand:false},
	]);
	
	//create component table for each of the sections.
	component.buildComponentTable(recordData.ALLOCATED,'phsa_cd_allocated','theTable');
	component.buildComponentTable(recordData.ISSUED,'phsa_cd_issued','theTable');
	component.buildComponentTable(recordData.PAST_THREE_MONTHS,'phsa_cd_previous_three_months','theTable');
	component.buildComponentTable(recordData.TRANSFUSION_REACTION_HISTORY,'phsa_cd_trans_reaction','theTable');
}
//helper function to build the component table for the subsections.
phsa_cd.blood_product_availability.prototype.buildComponentTable = function(tableData,id,class_name){
	var component = this;
	var compId = component.getComponentUid();
	var target = $("#"+compId+" #"+id+"");
	var table = new EPS.ComponentTable("<div class='mpage-no-results'>No results found</div>");
	table.setNamespace(""+compId+id+"");
	//if no data exists there is no need to execute this code.
	if(tableData != undefined && tableData.length > 0){
		table.setZebraStripe(true);
		// the transfusion reaction table has different columns than the other tables.
		if(id === "phsa_cd_trans_reaction"){
			var col1 = new EPS.TableColumn();
			col1.setColumnId("TEST");
			col1.setCustomClass("phsa_cd_test");
			col1.setColumnDisplay("Test");
			col1.setPrimarySortField("TEST");
			col1.setIsSortable(true);
			col1.setRenderTemplate('${TEST}');
			
			var col2 = new EPS.TableColumn();
			col2.setColumnId("RESULT");
			col2.setCustomClass("phsa_cd_result");
			col2.setColumnDisplay("Result");
			col2.setPrimarySortField("RESULT");
			col2.setIsSortable(true);
			col2.setRenderTemplate('${RESULT}');
			
			var col3 = new EPS.TableColumn();
			col3.setColumnId("DATE_TIME");
			col3.setCustomClass("phsa_cd_date_time");
			col3.setColumnDisplay("Date/Time");
			col3.setPrimarySortField("DATE_TIME_SORT");
			col3.setRenderTemplate('${DATE_TIME}');
			col3.setIsSortable(true);
			
			table.addColumn(col1);
			table.addColumn(col2);
			table.addColumn(col3);
		
			table.sortByColumnInDirection("DATE_TIME", EPS.TableColumn.SORT.DESCENDING);
			
			table.bindData(tableData);
		}else{
			var col1 = new EPS.TableColumn();
			col1.setColumnId("PRODUCT_NUMBER");
			col1.setCustomClass("phsa_cd_product_number");
			col1.setColumnDisplay("Product Number");
			col1.setPrimarySortField("PRODUCT_NUMBER");
			col1.setIsSortable(true);
			col1.setRenderTemplate('${PRODUCT_NUMBER}');
			
			var col2 = new EPS.TableColumn();
			col2.setColumnId("UNIT_DIVISION");
			col2.setCustomClass("phsa_cd_unit_division");
			col2.setColumnDisplay("Unit Division");
			col2.setPrimarySortField("UNIT_DIVISION");
			col2.setIsSortable(true);
			col2.setRenderTemplate('${UNIT_DIVISION}');
			
			var col3 = new EPS.TableColumn();
			col3.setColumnId("PRODUCT_NAME");
			col3.setCustomClass("phsa_cd_product_name");
			col3.setColumnDisplay("Product Name");
			col3.setPrimarySortField("PRODUCT_NAME");
			col3.setRenderTemplate('${PRODUCT_NAME}');
			col3.setIsSortable(true);
			
			var col4 = new EPS.TableColumn();
			col4.setColumnId("UNIT_STATUS");
			col4.setCustomClass("phsa_cd_unit_status");
			col4.setColumnDisplay("Unit Status");
			col4.setPrimarySortField("UNIT_STATUS");
			col4.setIsSortable(true);
			col4.setRenderTemplate('${UNIT_STATUS}');
			
			var col5 = new EPS.TableColumn();
			col5.setColumnId("STATUS_DT_TM");
			col5.setCustomClass("phsa_cd_status_dt");
			col5.setColumnDisplay("Status Date/Time");
			col5.setPrimarySortField("STATUS_DT_TM_SORT");
			col5.setIsSortable(true);
			col5.setRenderTemplate('${STATUS_DT_TM}');
			
			table.addColumn(col1);
			table.addColumn(col2);
			table.addColumn(col3);
			table.addColumn(col4);
			table.addColumn(col5);
			
			table.sortByColumnInDirection("STATUS_DT_TM", EPS.TableColumn.SORT.DESCENDING);
			
			table.bindData(tableData);
		}
	}
	target.html(table.render());
	table.finalize();
}


//Code Status
MPage.namespace("phsa_cd.code_status");

phsa_cd.code_status = function () {};
phsa_cd.code_status.prototype = new MPage.Component();
phsa_cd.code_status.prototype.constructor = MPage.Component;
phsa_cd.code_status.prototype.base = MPage.Component.prototype;
phsa_cd.code_status.prototype.name = "phsa_cd.code_status";
phsa_cd.code_status.prototype.cclProgram = "bc_all_comp_code_status";
phsa_cd.code_status.prototype.cclParams = [];
phsa_cd.code_status.prototype.cclDataType = "JSON";

phsa_cd.code_status.prototype.init = function () {
    var component = this;
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
    component.cclParams.push(this.getProperty("encounterId"));
    component.cclParams.push(1); // json flag
};

phsa_cd.code_status.prototype.addEventHandlers = function() {
	var component = this;
	var compId = component.getComponentUid();
	var target = component.getTarget();
	
};

phsa_cd.code_status.prototype.render = function () {
    var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();

    var tempData = component.data.CODE_STATUS;
    var targetHtml = [];
    
    //set the title text if needed (uncomment and update if needed)
    component.setProperty("headerTitle", "Code Status");
		
    targetHtml.push("<table>");
    targetHtml.push("<tbody>");
    targetHtml.push("<tr><td>*Resuscitation Status:</td>");
    targetHtml.push("<td>", tempData.RESUS_STATUS,"</td></tr>");
    targetHtml.push("<tr><td>Perioperative Status:");
    targetHtml.push("<td>", tempData.PER_STATUS,"</td></tr>");
    targetHtml.push("<tr><td>Chemotherapy Status:");
    targetHtml.push("<td>", tempData.CHEMO_STATUS,"</td></tr>");
    targetHtml.push("</tbody>");
    targetHtml.push("</table>");
    target.innerHTML = targetHtml.join("");
    //target.innerHTML = "Hello World!";
    component.addEventHandlers();

}

/* Anesthesia Patient Screening History */
MPage.namespace("phsa_cd.patient_screening_hist");

phsa_cd.patient_screening_hist = function () {
};
phsa_cd.patient_screening_hist.prototype = new MPage.Component();
phsa_cd.patient_screening_hist.prototype.constructor = MPage.Component;
phsa_cd.patient_screening_hist.prototype.base = MPage.Component.prototype;

phsa_cd.patient_screening_hist.prototype.init = function () {
    //code to perform before immediately rendering (usually updating params is needed)
    var component = this;
    var compId = component.getComponentUid();

    component.cclProgram = "bc_all_mp_anes_pat_screen_hist";

    //clear cclParams in case of refresh
    component.cclParams = [];
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
	component.cclParams.push(this.getProperty("encounterId"));
};

phsa_cd.patient_screening_hist.prototype.render = function () {
    var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();

    var sHTML = "";

    if (this.data.OUTREC != undefined) {
        var data = this.data.OUTREC.DATA;
        if (this.data.OUTREC.ERROR_IND == 1) {
            sHTML = this.data.OUTREC.ERROR_MSG;
        } else {

            sHTML = '<table><tbody>';
            var style = 'odd';

            for (i = 0; i < data.length; i++) {
                if (style == 'odd') style = 'even'
                else style = 'odd';
                sHTML += '<tr class="' + style + '">';
                sHTML += '<td>' + data[i].EVENT_TITLE_TXT + '</td>';
				sHTML += '<td>' + data[i].COMMENT_TXT + '</td>';
                sHTML += '</tr>';
            } //end loop through data

            sHTML += '</tbody></table>';
        }
    } else {
        sHTML = '<h2>ERROR: CCL script did not execute. Please report this errot to the reporting team</h2>'
    }

    target.innerHTML = sHTML; //"Hello from the Anest Patient Screening Component";

};

/* Oncology Medication Dispense */
MPage.namespace("phsa_cd.oncology_medication_dispense");

phsa_cd.oncology_medication_dispense = function () {
};
phsa_cd.oncology_medication_dispense.prototype = new MPage.Component();
phsa_cd.oncology_medication_dispense.prototype.constructor = MPage.Component;
phsa_cd.oncology_medication_dispense.prototype.base = MPage.Component.prototype;

phsa_cd.oncology_medication_dispense.prototype.init = function () {
    //code to perform before immediately rendering (usually updating params is needed)
    var component = this;
    var compId = component.getComponentUid();

    component.cclProgram = "bc_all_mp_onc_med_disp";

    //clear cclParams in case of refresh
    component.cclParams = [];
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
};

phsa_cd.oncology_medication_dispense.prototype.render = function () {
    var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();

    var sHTML = "";

    if (this.data.response != undefined) {
		sHTML += phsa_cd.custom_functions.table(compId + "_realtest", this.data.response.data, {
						titles: ["Cycle #", "Regimen Name", "Day of Treatment", "Treatment Date", "Drug Name", "Actual Dose", "Dose Adjust Reason", "Dose Administered", "Route", "CAP Indicator"],
//						colWidths: ["*","325px","*","*","250px","150px","250px","100px","*","*"],
						columns: ["cycle", "regimen", "dayOfTreatment", "treatmentDate", "drugName", "actualDose", "doseAdjustReason", "doseAdministered", "route", "capIndicator"],
						sort: {field: '', direction: 'asc'} //,
//						paginator: {size: 10, page: 1}
						});
    } else {
        sHTML = '<h2>ERROR: CCL script did not execute.</h2>'
    }

    target.innerHTML = sHTML; 

};

/* 
	Transfusion Information
*/
MPage.namespace("phsa_cd.bc_all_mp_transfusion_info");

phsa_cd.bc_all_mp_transfusion_info = function () {
};
phsa_cd.bc_all_mp_transfusion_info.prototype = new MPage.Component();
phsa_cd.bc_all_mp_transfusion_info.prototype.constructor = MPage.Component;
phsa_cd.bc_all_mp_transfusion_info.prototype.base = MPage.Component.prototype;

phsa_cd.bc_all_mp_transfusion_info.prototype.init = function () {
    //code to perform before immediately rendering (usually updating params is needed)
    var component = this;
    var compId = component.getComponentUid();

    component.cclProgram = "bc_all_mp_transfusion_info";

    //clear cclParams in case of refresh
    component.cclParams = [];
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
    component.cclParams.push(this.getProperty("encounterId"));
};


phsa_cd.bc_all_mp_transfusion_info.prototype.render = function () {
    var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();

    // Default message
    target.innerHTML = "No transfusion data exists for this visit.";
	
    if (this.data.customPre != undefined) {
	var transfusions = this.data.customPre[0].data.transfusions;
	
	if (transfusions.length > 0) {
		target.innerHTML = phsa_cd.custom_functions.table(compId + "_transfusions", transfusions, {
			columns: ["transfusionDtTm", "product", "volume", "unitNumber"],
			titles: ["Transfusion Dt/Tm", "Product Name", "Volume", "Unit Number"],
			sort: {field: 'product', direction: 'asc'}
		});
	}
    }
};


/*
	Custom PHSA Table function - minified source
*/
MPage.namespace("phsa_cd.custom_functions"),phsa_cd.custom_functions=function(){},phsa_cd.custom_functions.table=function(t,a,s){return void 0===phsa_cd.custom_functions.table.data&&(phsa_cd.custom_functions.table.data=[]),phsa_cd.custom_functions.table.data.push({name:t,data:a,properties:s}),phsa_cd.custom_functions.table.buildTable(phsa_cd.custom_functions.table.data.length-1)},phsa_cd.custom_functions.table.buildTable=function(t){var a="<div>No Data</div>";if(phsa_cd.custom_functions.table.data[t].data.length>0){var s=[];if(s=phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("sort")&&""!==phsa_cd.custom_functions.table.data[t].data.sort?phsa_cd.custom_functions.table.data[t].data.sort(phsa_cd.custom_functions.table.compareValues(phsa_cd.custom_functions.table.data[t].properties.sort.field,phsa_cd.custom_functions.table.data[t].properties.sort.direction)):phsa_cd.custom_functions.table.data[t].data,phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("paginator")){for(var o=(d=phsa_cd.custom_functions.table.data[t].properties.paginator.page)*(l=phsa_cd.custom_functions.table.data[t].properties.paginator.size)-l,e=Math.min(o+l,s.length),c=[],n=o;n<e;n++)c.push(s[n]);s=c}for(property in a='<div id="'+phsa_cd.custom_functions.table.data[t].name+'"><table class="table-layout: fixed;"><thead><tr>',_col=0,s[0]){if(!phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("columns")||_col<phsa_cd.custom_functions.table.data[t].properties.columns.length){var p="";phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("colWidths")&&(p="width:"+phsa_cd.custom_functions.table.data[t].properties.colWidths[_col]+";"),a+="<th";var i=property;phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("columns")&&_col<phsa_cd.custom_functions.table.data[t].properties.columns.length&&(i=phsa_cd.custom_functions.table.data[t].properties.columns[_col]),phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("sort")&&(a+=' style="cursor:pointer;'+p+'"',a+=' onclick="phsa_cd.custom_functions.table.sort('+t+",'"+i+"')\""),a+=">",phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("titles")&&phsa_cd.custom_functions.table.data[t].properties.titles.length>=_col?a+=phsa_cd.custom_functions.table.data[t].properties.titles[_col]:a+=i.toUpperCase(),phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("sort")&&(a+=phsa_cd.custom_functions.table.sortArrow(t,i)),a+="</th>"}_col++}a+="</tr></thead>",a+="<tbody>";var r="even";for(iRow=0;iRow<s.length;iRow++){for(nCol in a+='<tr class="'+(r="odd"==r?"even":"odd")+'">',_col=0,s[iRow]){if(phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("columns")){if(_col<phsa_cd.custom_functions.table.data[t].properties.columns.length){var u=s[iRow][phsa_cd.custom_functions.table.data[t].properties.columns[_col]];isNaN(Date.parse(u))?a+="<td>"+u+"</td>":(colDate=new Date(u),a+="<td>"+phsa_cd.custom_functions.table.appendZero(colDate.getDate())+"/"+phsa_cd.custom_functions.table.appendZero(colDate.getMonth()+1)+"/"+colDate.getFullYear()+" "+phsa_cd.custom_functions.table.appendZero(colDate.getHours())+":"+phsa_cd.custom_functions.table.appendZero(colDate.getMinutes())+"</td>")}}else a+="<td>"+s[iRow][nCol]+"</td>";_col++}a+="</tr>"}if(a+="</tbody></table>",phsa_cd.custom_functions.table.data[t].properties.hasOwnProperty("paginator")){var d,l;if(a+='<div style="padding: 4px; border-top: solid 1px;"><span>Showing '+((d=phsa_cd.custom_functions.table.data[t].properties.paginator.page)*(l=phsa_cd.custom_functions.table.data[t].properties.paginator.size)-l+1)+" to "+Math.min(d*l-l+l,phsa_cd.custom_functions.table.data[t].data.length)+" of "+phsa_cd.custom_functions.table.data[t].data.length+" entries</span>",a+='<span style="float:right">',phsa_cd.custom_functions.table.data[t].properties.paginator.hasOwnProperty("range")){for(a+='Show <select onchange="phsa_cd.custom_functions.table.changePageRange('+t+',value)">',rangeVal=0;rangeVal<phsa_cd.custom_functions.table.data[t].properties.paginator.range.length;rangeVal++)a+="<option",phsa_cd.custom_functions.table.data[t].properties.paginator.size==phsa_cd.custom_functions.table.data[t].properties.paginator.range[rangeVal]&&(a+=" selected"),a+=' value="'+phsa_cd.custom_functions.table.data[t].properties.paginator.range[rangeVal]+'">'+phsa_cd.custom_functions.table.data[t].properties.paginator.range[rangeVal]+"</option>";a+="</select> rows "}a+='<input type="button" value="First" onclick="phsa_cd.custom_functions.table.changePage('+t+',1)"><input type="button" value="Previous" onclick="phsa_cd.custom_functions.table.changePage('+t+',2)"><input type="button" value="Next" onclick="phsa_cd.custom_functions.table.changePage('+t+',3)"><input type="button" value="Last" onclick="phsa_cd.custom_functions.table.changePage('+t+',4)"></span></div>'}a+="</div>"}return a},phsa_cd.custom_functions.table.compareValues=function(t,a){return function(s,o){if(!s.hasOwnProperty(t)||!o.hasOwnProperty(t))return 0;var e=0;return e="string"==typeof s[t]?s[t].localeCompare(o[t]):s[t]<o[t]?-1:s[t]>o[t]?1:0,"desc"==a?-1*e:e}},phsa_cd.custom_functions.table.sort=function(t,a){var s="#"+phsa_cd.custom_functions.table.data[t].name;phsa_cd.custom_functions.table.data[t].properties.sort.field!=a?(phsa_cd.custom_functions.table.data[t].properties.sort.field=a,phsa_cd.custom_functions.table.data[t].properties.sort.direction="asc"):phsa_cd.custom_functions.table.data[t].properties.sort.direction="asc"==phsa_cd.custom_functions.table.data[t].properties.sort.direction?"desc":"asc",$(s).replaceWith(phsa_cd.custom_functions.table.buildTable(t))},phsa_cd.custom_functions.table.sortArrow=function(t,a){return phsa_cd.custom_functions.table.data[t].properties.sort.field!=a?" &nbsp;":"asc"==phsa_cd.custom_functions.table.data[t].properties.sort.direction?" &#9650;":" &#9660;"},phsa_cd.custom_functions.table.changePage=function(t,a){var s="#"+phsa_cd.custom_functions.table.data[t].name,o=phsa_cd.custom_functions.table.data[t].properties.paginator.size,e=phsa_cd.custom_functions.table.data[t].data.length,c=Math.ceil(e/o);1===a?phsa_cd.custom_functions.table.data[t].properties.paginator.page=1:2===a&&phsa_cd.custom_functions.table.data[t].properties.paginator.page>1?phsa_cd.custom_functions.table.data[t].properties.paginator.page--:3===a&&phsa_cd.custom_functions.table.data[t].properties.paginator.page<c?phsa_cd.custom_functions.table.data[t].properties.paginator.page++:4===a&&(phsa_cd.custom_functions.table.data[t].properties.paginator.page=c),$(s).replaceWith(phsa_cd.custom_functions.table.buildTable(t))},phsa_cd.custom_functions.table.changePageRange=function(t,a){var s="#"+phsa_cd.custom_functions.table.data[t].name;phsa_cd.custom_functions.table.data[t].properties.paginator.size=a,phsa_cd.custom_functions.table.data[t].properties.paginator.page=1,$(s).replaceWith(phsa_cd.custom_functions.table.buildTable(t))},phsa_cd.custom_functions.table.appendZero=function(t){return t<=9?"0"+t:t};

//Print-to-PDF Component
MPage.namespace("phsa_cd.p2pdf");

phsa_cd.p2pdf = function () {
};
phsa_cd.p2pdf.prototype = new MPage.Component();
phsa_cd.p2pdf.prototype.constructor = MPage.Component;
phsa_cd.p2pdf.prototype.base = MPage.Component.prototype;

phsa_cd.p2pdf.prototype.init = function () {
    //code to perform before immediately rendering (usually updating params is needed)
    var component = this;
    var compId = component.getComponentUid();

    component.cclProgram = "bc_all_mp_get_pdf";

    //clear cclParams in case of refresh
    component.cclParams = [];
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
	component.cclParams.push(this.getProperty("encounterId"));
};


phsa_cd.p2pdf.prototype.render = function () {
    var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();

    var sHTML = "";

    if (this.data.OUTREC != undefined) {
        var data = this.data.OUTREC.DATA;
        if (this.data.OUTREC.ERROR_IND == 1) {
            sHTML = '<p>' +  this.data.OUTREC.ERROR_MSG + '</p>';
        } else {

            sHTML = '<table id="pdftablelist"><tbody>';
            sHTML += '<tr><th onclick="p2pdfsortTable(0)">Document Date</th>';
            sHTML += '<th onclick="p2pdfsortTable(1)">Requested Start Date</th>';
	    sHTML += '<th onclick="p2pdfsortTable(2)">Status</th>';
   	    sHTML += '<th onclick="p2pdfsortTable(3)">Requisition</th>';
            sHTML += '<th onclick="p2pdfsortTable(4)">Ordering Provider</th></tr>';
            var style = 'odd';
	    var cclLinkParams = "'MINE',0";
	    var windowParams = "left=500,top=100,width=900,height=700,toolbar=no,resizable=yes,scrollbars=yes,status=no";
	    var pdfurl = "";
            for (i = 0; i < data.length; i++) {
                if (style == 'odd') style = 'even'
                else style = 'odd';
                sHTML += '<tr class="' + style + '">';
                sHTML += '<td>' + data[i].SERVICE_DT_TM_TXT + '</td>';
		sHTML += '<td>' + data[i].REQUESTED_START_DT_TM_TXT + '</td>';
                sHTML += '<td>' + data[i].STATUS + '</td>';
                sHTML += '<td><a href="javascript:p2pdflaunchWindow(' + data[i].CLINICAL_EVENT_ID +');">';
		sHTML += data[i].EVENT_TITLE_TXT;
		sHTML += '</a></td>';
		sHTML += '<td>' + data[i].ORDERING_PROVIDER + '</td>';
                sHTML += '</tr>';
            } //end loop through data

            sHTML += '</tbody></table>';
        }
    } else {
        sHTML = '<h2>ERROR: CCL script did not execute. Please report this errot to the reporting team</h2>'
    }

    target.innerHTML = sHTML; 

};

function p2pdfsortTable(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("pdftablelist");
  switching = true;
  // Set the sorting direction to ascending:
  dir = "asc";
  /* Make a loop that will continue until
  no switching has been done: */
  while (switching) {
    // Start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /* Loop through all table rows (except the
    first, which contains table headers): */
    for (i = 1; i < (rows.length - 1); i++) {
      // Start by saying there should be no switching:
      shouldSwitch = false;
      /* Get the two elements you want to compare,
      one from current row and one from the next: */
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];
      /* Check if the two rows should switch place,
      based on the direction, asc or desc: */
      if (dir == "asc") {
        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
          // If so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      } else if (dir == "desc") {
        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
          // If so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      /* If a switch has been marked, make the switch
      and mark that a switch has been done: */
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      // Each time a switch is done, increase this count by 1:
      switchcount ++;
    } else {
      /* If no switching has been done AND the direction is "asc",
      set the direction to "desc" and run the while loop again. */
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}
function p2pdflaunchWindow(eventid) {
	 	var fwObj = window.external.DiscernObjectFactory("PVFRAMEWORKLINK");
	 	var cclParams = '"MINE",'+eventid;
		fwObj.SetPopupStringProp("REPORT_NAME","bc_all_mp_pdf_viewer");
		fwObj.SetPopupStringProp("REPORT_PARAM",cclParams);
		fwObj.SetPopupBoolProp("SHOW_BUTTONS",0);
		fwObj.SetPopupBoolProp("MODAL",0);
		fwObj.SetPopupDoubleProp("WIDTH",600);
		fwObj.SetPopupDoubleProp("HEIGHT",500);
		fwObj.LaunchPopup();
};

//Print-to-PDF Component Development
MPage.namespace("phsa_cd.p2pdf_dev");

var sort_option = "des"

phsa_cd.p2pdf_dev = function () {};
phsa_cd.p2pdf_dev.prototype = new MPage.Component();
phsa_cd.p2pdf_dev.prototype.constructor = MPage.Component;
phsa_cd.p2pdf_dev.prototype.base = MPage.Component.prototype;
phsa_cd.p2pdf_dev.prototype.init = function () {
    //code to perform before immediately rendering (usually updating params is needed)
    var component = this;
    var compId = component.getComponentUid();

    component.cclProgram = "bc_all_mp_get_pdf_dev";

    //clear cclParams in case of refresh
    component.cclParams = [];
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
    component.cclParams.push(this.getProperty("encounterId"));
    component.cclDataType = "JSON";
};

phsa_cd.p2pdf_dev.prototype.render = function () {
	var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();

    var sHTML = "";
	sHTML = '<div id="pdfcontents_'+compId+'"></div>';
	target.innerHTML = sHTML;
	
	phsa_cd.p2pdf_dev.renderScriptResults(component);
	
};      

phsa_cd.p2pdf_dev.renderSortResults = function(component, selection){
	
	switch(selection){
		case 'sort_ordered_date':
			component.data.OUTREC.DATA.sort(GetSortOrder("DOCUMENT_DATE_SORT","REQUISITION_SORT"))
			break;
		case 'sort_requested_date':
			component.data.OUTREC.DATA.sort(GetSortOrder("REQUESTED_DATE_SORT","REQUISITION_SORT"))
			break;
		case 'sort_status':
			component.data.OUTREC.DATA.sort(GetSortOrder("STATUS_SORT","REQUESTED_DATE_SORT"))
			break;
		case 'sort_requisition':
			component.data.OUTREC.DATA.sort(GetSortOrder("REQUISITION_SORT","REQUESTED_DATE_SORT"))
			break;
		case 'sort_ordering_provider':
			component.data.OUTREC.DATA.sort(GetSortOrder("PROVIDER_SORT","REQUESTED_DATE_SORT"))
			break;
	}
	
	function GetSortOrder(prop1, prop2) {    
		return function(a, b) {  
			if (a[prop1] > b[prop1]) {  
				return -1;  
			} else if (a[prop1] < b[prop1]) {  
				return 1;  
			}  
			else {
				if (a[prop2] > b[prop2]) {  
					return 1;  
				} else if (a[prop2] < b[prop2]) {  
					return -1;  
				} else {
					return 0;
				}
			} 
		}
	}		
	if (sort_option == "des") {
		component.data.OUTREC.DATA.reverse()
		sort_option = "asc"
	} else {
		sort_option = "des"
	}
	phsa_cd.p2pdf_dev.renderScriptResults(component);
	
};

phsa_cd.p2pdf_dev.renderScriptResults = function(component){
	var scriptDispObj;
	var elementObj;
	var compId;
	var style = 'odd';
	var cclLinkParams = "'MINE',0";
	var windowParams = "left=500,top=100,width=900,height=700,toolbar=no,resizable=yes,scrollbars=yes,status=no";
	var pdfurl = "";
	var sHTML = "";
	
	compId = component.getComponentUid();
	scriptDispObj = document.getElementById("pdfcontents_" + compId); 

	sHTML = '<table id="pdftablelistdev_'+compId+'" width=100%><thead>';
    sHTML += '<tr>'
	sHTML += '<th style="cursor:default;width:100px" id="sort_ordered_date'+compId+'">Ordered Date</th>';
	sHTML += '<th style="cursor:default;width:100px" id="sort_requested_date'+compId+'">Requested Start Date</th>';
	sHTML += '<th style="cursor:default;width:65px" id="sort_status'+compId+'">Status</th>';
	sHTML += '<th style="cursor:default;" id="sort_requisition'+compId+'">Requisition</th>';
    sHTML += '<th style="cursor:default;" id="sort_ordering_provider'+compId+'">Ordering Provider</th>';
	sHTML += '</tr></thead>';
	
	var data = component.data.OUTREC.DATA;
    sHTML += '<tbody">'
	
	for (i = 0; i < data.length; i++) {
            if (style == 'odd') style = 'even'
            else style = 'odd';
            sHTML += '<tr class="' + style + '">';
            sHTML += '<td>' + data[i].SERVICE_DT_TM_TXT.split(' ').join('<br>') + '</td>';
			sHTML += '<td>' + data[i].REQUESTED_START_DT_TM_TXT.split(' ').join('<br>') + '</td>';
            sHTML += '<td>' + data[i].STATUS + '</td>';
            sHTML += '<td><a href="javascript:p2pdflaunchWindow_dev(' + data[i].CLINICAL_EVENT_ID +');">';
			sHTML += data[i].EVENT_TITLE_TXT;
			sHTML += '</a></td>';
			sHTML += '<td>' + data[i].ORDERING_PROVIDER + '</td>';
			/*sHTML += '<td>';
			sHTML += '<div style="display:none;">'+data[i].DOCUMENT_DATE_SORT+'</div>';
			sHTML += '<div style="display:none;">'+data[i].REQUESTED_DATE_SORT+'</div>';
			sHTML += '<div style="display:none;">'+data[i].STATUS_SORT+'</div>';
			sHTML += '<div style="display:none;">'+data[i].REQUISITION_SORT+'</div>';
			sHTML += '<div style="display:none;">'+data[i].PROVIDER_SORT+'</div>';
			sHTML += '</td>';*/
            sHTML += '</tr>';
        } //end loop through data

    sHTML += '</tbody></table>';
	scriptDispObj.innerHTML = sHTML
	
	elementObj = document.getElementById('sort_ordered_date' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_dev.renderSortResults(component,'sort_ordered_date')};
	elementObj = document.getElementById('sort_requested_date' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_dev.renderSortResults(component,'sort_requested_date')};
	elementObj = document.getElementById('sort_status' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_dev.renderSortResults(component,'sort_status')};
	elementObj = document.getElementById('sort_requisition' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_dev.renderSortResults(component,'sort_requisition')};
	elementObj = document.getElementById('sort_ordering_provider' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_dev.renderSortResults(component,'sort_ordering_provider')};
};

function p2pdfsortTable_dev(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("pdftablelistdev");
  switching = true;
  // Set the sorting direction to ascending:
  dir = "asc";
  /* Make a loop that will continue until
  no switching has been done: */
  while (switching) {
    // Start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /* Loop through all table rows (except the
    first, which contains table headers): */
    for (i = 1; i < (rows.length - 1); i++) {
      // Start by saying there should be no switching:
      shouldSwitch = false;
      /* Get the two elements you want to compare,
      one from current row and one from the next: */
      x = rows[i].getElementsByTagName("DIV")[n];
      y = rows[i + 1].getElementsByTagName("DIV")[n];
      /* Check if the two rows should switch place,
      based on the direction, asc or desc: */
      if (dir == "asc") {
        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
          // If so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      } else if (dir == "desc") {
        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
          // If so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      /* If a switch has been marked, make the switch
      and mark that a switch has been done: */
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      // Each time a switch is done, increase this count by 1:
      switchcount ++;
    } else {
      /* If no switching has been done AND the direction is "asc",
      set the direction to "desc" and run the while loop again. */
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}
function p2pdflaunchWindow_dev(eventid) {
	 	var fwObj = window.external.DiscernObjectFactory("PVFRAMEWORKLINK");
	 	var cclParams = '"MINE",'+eventid;
		fwObj.SetPopupStringProp("REPORT_NAME","dev_all_mp_pdf_viewer");
		fwObj.SetPopupStringProp("REPORT_PARAM",cclParams);
		fwObj.SetPopupBoolProp("SHOW_BUTTONS",0);
		fwObj.SetPopupBoolProp("MODAL",0);
		fwObj.SetPopupDoubleProp("WIDTH",600);
		fwObj.SetPopupDoubleProp("HEIGHT",500);
		fwObj.LaunchPopup();
		
		//update 5
};

//Print-to-PDF Component RM View
MPage.namespace("phsa_cd.p2pdf_rm");

var sort_option = "des"

phsa_cd.p2pdf_rm = function () {};
phsa_cd.p2pdf_rm.prototype = new MPage.Component();
phsa_cd.p2pdf_rm.prototype.constructor = MPage.Component;
phsa_cd.p2pdf_rm.prototype.base = MPage.Component.prototype;
phsa_cd.p2pdf_rm.prototype.init = function () {
    //code to perform before immediately rendering (usually updating params is needed)
    var component = this;
    var compId = component.getComponentUid();

    component.cclProgram = "bc_all_mp_get_pdf_rm";

    //clear cclParams in case of refresh
    component.cclParams = [];
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
    component.cclParams.push(this.getProperty("encounterId"));
    component.cclDataType = "JSON";
};

phsa_cd.p2pdf_rm.prototype.render = function () {
	var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();

    var sHTML = "";
	sHTML = '<div id="pdfcontents_'+compId+'"></div>';
	target.innerHTML = sHTML;
	
	phsa_cd.p2pdf_rm.renderScriptResults(component);
	
};      

phsa_cd.p2pdf_rm.renderSortResults = function(component, selection){
	
	switch(selection){
		case 'sort_ordered_date':
			component.data.OUTREC.DATA.sort(GetSortOrder("DOCUMENT_DATE_SORT","REQUISITION_SORT"))
			break;
		case 'sort_requested_date':
			component.data.OUTREC.DATA.sort(GetSortOrder("REQUESTED_DATE_SORT","REQUISITION_SORT"))
			break;
		case 'sort_status':
			component.data.OUTREC.DATA.sort(GetSortOrder("STATUS_SORT","REQUESTED_DATE_SORT"))
			break;
		case 'sort_requisition':
			component.data.OUTREC.DATA.sort(GetSortOrder("REQUISITION_SORT","REQUESTED_DATE_SORT"))
			break;
		case 'sort_ordering_provider':
			component.data.OUTREC.DATA.sort(GetSortOrder("PROVIDER_SORT","REQUESTED_DATE_SORT"))
			break;
		case 'sort_requisition_status':
			component.data.OUTREC.DATA.sort(GetSortOrder("REQUISITION_STATUS_SORT","REQUESTED_DATE_SORT"))
			break;
		case 'sort_comment':
			component.data.OUTREC.DATA.sort(GetSortOrder("COMMENT_SORT","REQUESTED_DATE_SORT"))
			break;
		case 'sort_unit':
			component.data.OUTREC.DATA.sort(GetSortOrder("UNIT_SORT","REQUESTED_DATE_SORT"))
			break;
	}
	
	function GetSortOrder(prop1, prop2) {    
		return function(a, b) {  
			if (a[prop1] > b[prop1]) {  
				return -1;  
			} else if (a[prop1] < b[prop1]) {  
				return 1;  
			}  
			else {
				if (a[prop2] > b[prop2]) {  
					return 1;  
				} else if (a[prop2] < b[prop2]) {  
					return -1;  
				} else {
					return 0;
				}
			} 
		}
	}		
	if (sort_option == "des") {
		component.data.OUTREC.DATA.reverse()
		sort_option = "asc"
	} else {
		sort_option = "des"
	}
	phsa_cd.p2pdf_rm.renderScriptResults(component);
	
};

phsa_cd.p2pdf_rm.renderScriptResults = function(component){
	var scriptDispObj;
	var elementObj;
	var compId;
	var style = 'odd';
	var cclLinkParams = "'MINE',0";
	var windowParams = "left=500,top=100,width=900,height=700,toolbar=no,resizable=yes,scrollbars=yes,status=no";
	var pdfurl = "";
	var sHTML = "";
	
	compId = component.getComponentUid();
	scriptDispObj = document.getElementById("pdfcontents_" + compId); 

	sHTML = '<table id="pdftablelistrm_'+compId+'" width=100%><thead>';
    sHTML += '<tr>'
	sHTML += '<th style="cursor:default;width:100px" id="sort_ordered_date'+compId+'">Ordered Date</th>';
	sHTML += '<th style="cursor:default;width:100px" id="sort_requested_date'+compId+'">Requested Start Date</th>';
	sHTML += '<th style="cursor:default;" id="sort_requisition'+compId+'">Requisition</th>';
	sHTML += '<th style="cursor:default;width:65px" id="sort_status'+compId+'">Print Status</th>';
	sHTML += '<th style="cursor:default;width:125px" id="sort_requisition_status'+compId+'">Requisition Status</th>';
	sHTML += '<th style="cursor:default;width:150px" id="sort_comment'+compId+'">Comment</th>';
	sHTML += '<th style="cursor:default;width:10px" ></th>';
    	sHTML += '<th style="cursor:default;" id="sort_ordering_provider'+compId+'">Ordering Provider</th>';
	sHTML += '<th style="cursor:default;width:150px" id="sort_unit'+compId+'">Order Location</th>';
	sHTML += '</tr></thead>';
	
	var data = component.data.OUTREC.DATA;
    sHTML += '<tbody">'
	
	for (i = 0; i < data.length; i++) {
            if (style == 'odd') style = 'even'
            else style = 'odd';
            sHTML += '<tr class="' + style + '">';
            sHTML += '<td>' + data[i].SERVICE_DT_TM_TXT.split(' ').join('<br>') + '</td>';
			sHTML += '<td>' + data[i].REQUESTED_START_DT_TM_TXT.split(' ').join('<br>') + '</td>';
          
            sHTML += '<td><a href="javascript:p2pdflaunchWindow_dev(' + data[i].CLINICAL_EVENT_ID +');">';
			sHTML += data[i].EVENT_TITLE_TXT;
			sHTML += '</a></td>';
		if (data[i].STATUS == "Printed") {
			sHTML += '<td><i>' + data[i].STATUS + '</i></td>';
		} else {
			sHTML += '<td>' + data[i].STATUS + '</td>';
		}
		sHTML += '<td>' + data[i].REQUISITION_STATUS.split(',').join('<br>')  + '</td>';
		sHTML += '<td><div style="word-wrap:break-word;max-width:150px;width:150px">' + data[i].COMMENT + '</div></td>';
		sHTML += '<td></td>';
		sHTML += '<td>' + data[i].ORDERING_PROVIDER + '</td>';
		sHTML += '<td>' + data[i].UNIT + '</td>';
            sHTML += '</tr>';
        } //end loop through data

    sHTML += '</tbody></table>';
	scriptDispObj.innerHTML = sHTML
	
	elementObj = document.getElementById('sort_ordered_date' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_rm.renderSortResults(component,'sort_ordered_date')};
	
	elementObj = document.getElementById('sort_requested_date' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_rm.renderSortResults(component,'sort_requested_date')};
	
	elementObj = document.getElementById('sort_comment' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_rm.renderSortResults(component,'sort_comment')};
	
	elementObj = document.getElementById('sort_status' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_rm.renderSortResults(component,'sort_status')};
	
	elementObj = document.getElementById('sort_requisition_status' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_rm.renderSortResults(component,'sort_requisition_status')};
	
	elementObj = document.getElementById('sort_requisition' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_rm.renderSortResults(component,'sort_requisition')};
	
	elementObj = document.getElementById('sort_ordering_provider' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_rm.renderSortResults(component,'sort_ordering_provider')};

	elementObj = document.getElementById('sort_unit' + compId);
	elementObj.onclick = function(){phsa_cd.p2pdf_rm.renderSortResults(component,'sort_unit')};
};

/* START - Intraoperative Medications */
MPage.namespace("phsa_cd.bc_all_mp_intraop_meds");

phsa_cd.bc_all_mp_intraop_meds = function () {
};
phsa_cd.bc_all_mp_intraop_meds.prototype = new MPage.Component();
phsa_cd.bc_all_mp_intraop_meds.prototype.constructor = MPage.Component;
phsa_cd.bc_all_mp_intraop_meds.prototype.base = MPage.Component.prototype;

phsa_cd.bc_all_mp_intraop_meds.prototype.init = function () {
    var component = this;
    var compId = component.getComponentUid();

    component.cclProgram = "bc_all_mp_intraop_meds:group1";

    //clear cclParams in case of refresh
	component.cclParams = [];
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
    component.cclParams.push(this.getProperty("encounterId"));
};

phsa_cd.bc_all_mp_intraop_meds.prototype.render = function () {
    var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();

	var sHTML = '<div class="ltd-container">';
	
	if (this.data.customPre != undefined && this.data.customPre[0].data.data.length > 0) {
		var refCount = this.data.customPre[0].data.ref.length;
		var data = this.data.customPre[0].data.data;
		
		sHTML += '<table class="ltd-box">';
		
		// Loop through each row of reference data and build out table row
		for (var row = 0; row < refCount; row++) {
			// Write header row for first value
			if (row == 0) {
				for (var col = 0; col < data.length; col++) {
					sClass = 'ltd-data-column';
					if (col == 0) {
						sHTML += '<tr class="ltd-tr">';
						sClass = 'ltd-label-column';
					}
					sHTML += '<td class="' + sClass + ' ltd-row0">' + data[col].label + '</td>';
					if (col == data.length - 1) {
						sHTML += '</tr>';
					}
				}
			}

			// Write the data columns
			for (var col = 0; col < data.length; col++) {			
				sClass = 'ltd-data-column';
				if (col == 0) {
					sHTML += '<tr class="ltd-tr">';
					sClass = 'ltd-label-column';
					sHTML += '<td class="' + sClass + '">' + data[col].results[row] + '</td>';
				} else {
					sHTML += '<td class="' + sClass + '"><span title="' + data[col].results[row] + '">'  + data[col].results[row] +  '</span></td>';
				}
				if (col == data.length - 1) {
					sHTML += '</tr>';
				}
				
			}
		}
		
		sHTML += '</table>';		
		
	} else {
		sHTML += '<span class="ltd-mpage-no-results">No results found.</span>';
	}
	
	sHTML += '</div>';
	
	target.innerHTML = sHTML;
};
/* END - Intraoperative Medications */


/* BEGIN - Clinical Office Integration */
/* iFrameResizer library - Needed to embed Clinical Office MPages into Cerner Component Framework */
!function(u){var f,l,a,x,M,I,k,r,m,F,t,g,z;function h(){return window.MutationObserver||window.WebKitMutationObserver||window.MozMutationObserver}function O(e,n,t){e.addEventListener(n,t,!1)}function R(e,n,t){e.removeEventListener(n,t,!1)}function o(e){return M+"["+(e="Host page: "+(n=e),e=window.top!==window.self?window.parentIFrame&&window.parentIFrame.getId?window.parentIFrame.getId()+": "+n:"Nested host page: "+n:e)+"]";var n}function i(e){return F[e]?F[e].log:l}function T(e,n){s("log",e,n,i(e))}function E(e,n){s("info",e,n,i(e))}function N(e,n){s("warn",e,n,!0)}function s(e,n,t,i){!0===i&&"object"==typeof window.console&&console[e](o(n),t)}function e(n){function t(){i("Height"),i("Width"),L(function(){A(y),H(v),l("onResized",y)},y,"init")}function e(){var e=b.substr(I).split(":"),n=e[1]?parseInt(e[1],10):0,t=F[e[0]]&&F[e[0]].iframe,i=getComputedStyle(t);return{iframe:t,id:e[0],height:n+function(e){if("border-box"!==e.boxSizing)return 0;var n=e.paddingTop?parseInt(e.paddingTop,10):0,e=e.paddingBottom?parseInt(e.paddingBottom,10):0;return n+e}(i)+function(e){if("border-box"!==e.boxSizing)return 0;var n=e.borderTopWidth?parseInt(e.borderTopWidth,10):0,e=e.borderBottomWidth?parseInt(e.borderBottomWidth,10):0;return n+e}(i),width:e[2],type:e[3]}}function i(e){var n=Number(F[v]["max"+e]),t=Number(F[v]["min"+e]),i=e.toLowerCase(),e=Number(y[i]);T(v,"Checking "+i+" is in range "+t+"-"+n),e<t&&(e=t,T(v,"Set "+i+" to min value")),n<e&&(e=n,T(v,"Set "+i+" to max value")),y[i]=""+e}function o(){function e(){return i.constructor===Array?function(){var e=0,n=!1;for(T(v,"Checking connection is from allowed list of origins: "+i);e<i.length;e++)if(i[e]===t){n=!0;break}return n}():(e=F[v]&&F[v].remoteHost,T(v,"Checking connection is from: "+e),t===e);var e}var t=n.origin,i=F[v]&&F[v].checkOrigin;if(i&&""+t!="null"&&!e())throw new Error("Unexpected message received from: "+t+" for "+y.iframe.id+". Message was: "+n.data+". This error can be disabled by setting the checkOrigin: false option or by providing of array of trusted domains.");return 1}function a(e){return b.substr(b.indexOf(":")+x+e)}function s(t,i){var e,n,o;e=function(){var e,n;B("Send Page Info","pageInfo:"+(e=document.body.getBoundingClientRect(),n=y.iframe.getBoundingClientRect(),JSON.stringify({iframeHeight:n.height,iframeWidth:n.width,clientHeight:Math.max(document.documentElement.clientHeight,window.innerHeight||0),clientWidth:Math.max(document.documentElement.clientWidth,window.innerWidth||0),offsetTop:parseInt(n.top-e.top,10),offsetLeft:parseInt(n.left-e.left,10),scrollTop:window.pageYOffset,scrollLeft:window.pageXOffset,documentHeight:document.documentElement.clientHeight,documentWidth:document.documentElement.clientWidth,windowHeight:window.innerHeight,windowWidth:window.innerWidth})),t,i)},n=32,z[o=i]||(z[o]=setTimeout(function(){z[o]=null,e()},n))}function r(e){e=e.getBoundingClientRect();return S(v),{x:Math.floor(Number(e.left)+Number(k.x)),y:Math.floor(Number(e.top)+Number(k.y))}}function d(e){var n=e?r(y.iframe):{x:0,y:0},t={x:Number(y.width)+n.x,y:Number(y.height)+n.y};T(v,"Reposition requested from iFrame (offset x:"+n.x+" y:"+n.y+")"),window.top!==window.self?window.parentIFrame?window.parentIFrame["scrollTo"+(e?"Offset":"")](t.x,t.y):N(v,"Unable to scroll to requested position, window.parentIFrame not found"):(k=t,c(),T(v,"--"))}function c(){!1!==l("onScroll",k)?H(v):j()}function u(e){var n,t=e.split("#")[1]||"",e=decodeURIComponent(t),i=document.getElementById(e)||document.getElementsByName(e)[0];i?(n=r(i),T(v,"Moving to in page link (#"+t+") at x: "+n.x+" y: "+n.y),k={x:n.x,y:n.y},c(),T(v,"--")):window.top!==window.self?window.parentIFrame?window.parentIFrame.moveToAnchor(t):T(v,"In page link #"+t+" not found and window.parentIFrame not found"):T(v,"In page link #"+t+" not found")}function f(e){var n,t={};t=0===Number(y.width)&&0===Number(y.height)?{x:(n=a(9).split(":"))[1],y:n[0]}:{x:y.width,y:y.height},l(e,{iframe:y.iframe,screenX:Number(t.x),screenY:Number(t.y),type:y.type})}function l(e,n){return W(v,e,n)}function m(){switch(F[v]&&F[v].firstRun&&F[v]&&(F[v].firstRun=!1),y.type){case"close":C(y.iframe);break;case"message":n=a(6),T(v,"onMessage passed: {iframe: "+y.iframe.id+", message: "+n+"}"),l("onMessage",{iframe:y.iframe,message:JSON.parse(n)}),T(v,"--");break;case"mouseenter":f("onMouseEnter");break;case"mouseleave":f("onMouseLeave");break;case"autoResize":F[v].autoResize=JSON.parse(a(9));break;case"scrollTo":d(!1);break;case"scrollToOffset":d(!0);break;case"pageInfo":s(F[v]&&F[v].iframe,v),r=v,e("Add ",O),F[r]&&(F[r].stopPageInfo=o);break;case"pageInfoStop":F[v]&&F[v].stopPageInfo&&(F[v].stopPageInfo(),delete F[v].stopPageInfo);break;case"inPageLink":u(a(9));break;case"reset":P(y);break;case"init":t(),l("onInit",y.iframe);break;default:0===Number(y.width)&&0===Number(y.height)?N("Unsupported message received ("+y.type+"), this is likely due to the iframe containing a later version of iframe-resizer than the parent page"):t()}function e(n,t){function i(){F[r]?s(F[r].iframe,r):o()}["scroll","resize"].forEach(function(e){T(r,n+e+" listener for sendPageInfo"),t(window,e,i)})}function o(){e("Remove ",R)}var r,n}var g,h,p,w,b=n.data,y={},v=null;"[iFrameResizerChild]Ready"===b?function(){for(var e in F)B("iFrame requested init",q(e),F[e].iframe,e)}():M===(""+b).substr(0,I)&&b.substr(I).split(":")[0]in F?(y=e(),v=y.id,F[v]&&(F[v].loaded=!0),(w=y.type in{true:1,false:1,undefined:1})&&T(v,"Ignoring init message from meta parent page"),!w&&(p=!0,F[h=v]||(p=!1,N(y.type+" No settings for "+h+". Message was: "+b)),p)&&(T(v,"Received: "+b),g=!0,null===y.iframe&&(N(v,"IFrame ("+y.id+") not found"),g=!1),g&&o()&&m())):E(v,"Ignored: "+b)}function W(e,n,t){var i=null,o=null;if(F[e]){if("function"!=typeof(i=F[e][n]))throw new TypeError(n+" on iFrame["+e+"] is not a function");o=i(t)}return o}function p(e){e=e.id;delete F[e]}function C(e){var n=e.id;if(!1!==W(n,"onClose",n)){T(n,"Removing iFrame: "+n);try{e.parentNode&&e.parentNode.removeChild(e)}catch(e){N(e)}W(n,"onClosed",n),T(n,"--"),p(e)}else T(n,"Close iframe cancelled by onClose event")}function S(e){null===k&&T(e,"Get page position: "+(k={x:window.pageXOffset!==u?window.pageXOffset:document.documentElement.scrollLeft,y:window.pageYOffset!==u?window.pageYOffset:document.documentElement.scrollTop}).x+","+k.y)}function H(e){null!==k&&(window.scrollTo(k.x,k.y),T(e,"Set page position: "+k.x+","+k.y),j())}function j(){k=null}function P(e){T(e.id,"Size reset requested by "+("init"===e.type?"host page":"iFrame")),S(e.id),L(function(){A(e),B("reset","reset",e.iframe,e.id)},e,"reset")}function A(o){function t(e){function n(){Object.keys(F).forEach(function(e){function n(e){return"0px"===(F[t]&&F[t].iframe.style[e])}var t;F[t=e]&&null!==F[t].iframe.offsetParent&&(n("height")||n("width"))&&B("Visibility change","resize",F[t].iframe,t)})}function t(e){T("window","Mutation observed: "+e[0].target+" "+e[0].type),c(n,16)}var i;a||"0"!==o[e]||(a=!0,T(r,"Hidden iFrame detected, creating visibility listener"),(i=h())&&function(){var e=document.querySelector("body");new i(t).observe(e,{attributes:!0,attributeOldValue:!1,characterData:!0,characterDataOldValue:!1,childList:!0,subtree:!0})}())}function e(e){var n;n=e,o.id?(o.iframe.style[n]=o[n]+"px",T(o.id,"IFrame ("+r+") "+n+" set to "+o[n]+"px")):T("undefined","messageData id not set"),t(e)}var r=o.iframe.id;F[r]&&(F[r].sizeHeight&&e("height"),F[r].sizeWidth&&e("width"))}function L(e,n,t){t!==n.type&&r&&!window.jasmine?(T(n.id,"Requesting animation frame"),r(e)):e()}function B(n,t,i,o,e){function r(){var e;i&&"contentWindow"in i&&null!==i.contentWindow?(e=F[o]&&F[o].targetOrigin,T(o,"["+n+"] Sending msg to iframe["+o+"] ("+t+") targetOrigin: "+e),i.contentWindow.postMessage(M+t,e)):N(o,"["+n+"] IFrame("+o+") not found")}function a(){e&&F[o]&&F[o].warningTimeout&&(F[o].msgTimeout=setTimeout(function(){!F[o]||F[o].loaded||s||(s=!0,N(o,"IFrame has not responded within "+F[o].warningTimeout/1e3+" seconds. Check iFrameResizer.contentWindow.js has been loaded in iFrame. This message can be ignored if everything is working, or you can set the warningTimeout option to a higher value or zero to suppress this warning."))},F[o].warningTimeout))}var s=!1;o=o||i.id,F[o]&&(r(),a())}function q(e){return e+":"+F[e].bodyMarginV1+":"+F[e].sizeWidth+":"+F[e].log+":"+F[e].interval+":"+F[e].enablePublicMethods+":"+F[e].autoResize+":"+F[e].bodyMargin+":"+F[e].heightCalculationMethod+":"+F[e].bodyBackground+":"+F[e].bodyPadding+":"+F[e].tolerance+":"+F[e].inPageLinks+":"+F[e].resizeFrom+":"+F[e].widthCalculationMethod+":"+F[e].mouseEvents}function d(i,e){function n(t){var e,n=h();n&&(e=n,i.parentNode&&new e(function(e){e.forEach(function(e){Array.prototype.slice.call(e.removedNodes).forEach(function(e){e===i&&C(i)})})}).observe(i.parentNode,{childList:!0})),O(i,"load",function(){var e,n;B("iFrame.onload",t,i,u,!0),e=F[s]&&F[s].firstRun,n=F[s]&&F[s].heightCalculationMethod in m,!e&&n&&P({iframe:i,height:0,width:0,type:"init"})}),B("init",t,i,u,!0)}function t(e){var n=e.split("Callback");2===n.length&&(this[n="on"+n[0].charAt(0).toUpperCase()+n[0].slice(1)]=this[e],delete this[e],N(s,"Deprecated: '"+e+"' has been renamed '"+n+"'. The old method will be removed in the next major version."))}function o(e){e=e||{},F[s]={firstRun:!0,iframe:i,remoteHost:i.src&&i.src.split("/").slice(0,3).join("/")},function(e){if("object"!=typeof e)throw new TypeError("Options is not an object")}(e),Object.keys(e).forEach(t,e),function(e){for(var n in g)Object.prototype.hasOwnProperty.call(g,n)&&(F[s][n]=(Object.prototype.hasOwnProperty.call(e,n)?e:g)[n])}(e),F[s]&&(F[s].targetOrigin=!0===F[s].checkOrigin?""===(e=F[s].remoteHost)||null!==e.match(/^(about:blank|javascript:|file:\/\/)/)?"*":e:"*")}var r,a,s=(""===(r=i.id)&&(i.id=(a=e&&e.id||g.id+f++,null!==document.getElementById(a)&&(a+=f++),r=a),l=(e||{}).log,T(r,"Added missing iframe ID: "+r+" ("+i.src+")")),r);function d(e){var n=F[s][e];1/0!==n&&0!==n&&(i.style[e]="number"==typeof n?n+"px":n,T(s,"Set "+e+" = "+i.style[e]))}function c(e){if(F[s]["min"+e]>F[s]["max"+e])throw new Error("Value for min"+e+" can not be greater than max"+e)}s in F&&"iFrameResizer"in i?N(s,"Ignored iFrame, already setup."):(o(e),function(){switch(T(s,"IFrame scrolling "+(F[s]&&F[s].scrolling?"enabled":"disabled")+" for "+s),i.style.overflow=!1===(F[s]&&F[s].scrolling)?"hidden":"auto",F[s]&&F[s].scrolling){case"omit":break;case!0:i.scrolling="yes";break;case!1:i.scrolling="no";break;default:i.scrolling=F[s]?F[s].scrolling:"no"}}(),c("Height"),c("Width"),d("maxHeight"),d("minHeight"),d("maxWidth"),d("minWidth"),"number"!=typeof(F[s]&&F[s].bodyMargin)&&"0"!==(F[s]&&F[s].bodyMargin)||(F[s].bodyMarginV1=F[s].bodyMargin,F[s].bodyMargin=F[s].bodyMargin+"px"),n(q(s)),F[s]&&(F[s].iframe.iFrameResizer={close:C.bind(null,F[s].iframe),removeListeners:p.bind(null,F[s].iframe),resize:B.bind(null,"Window resize","resize",F[s].iframe),moveToAnchor:function(e){B("Move to anchor","moveToAnchor:"+e,F[s].iframe,s)},sendMessage:function(e){B("Send Message","message:"+(e=JSON.stringify(e)),F[s].iframe,s)}}))}function c(e,n){null===t&&(t=setTimeout(function(){t=null,e()},n))}function n(){"hidden"!==document.visibilityState&&(T("document","Trigger event: Visiblity change"),c(function(){w("Tab Visable","resize")},16))}function w(t,i){Object.keys(F).forEach(function(e){var n;F[n=e]&&"parent"===F[n].resizeFrom&&F[n].autoResize&&!F[n].firstRun&&B(t,i,F[e].iframe,e)})}function b(){O(window,"message",e),O(window,"resize",function(){var e;T("window","Trigger event: "+(e="resize")),c(function(){w("Window "+e,"resize")},16)}),O(document,"visibilitychange",n),O(document,"-webkit-visibilitychange",n)}function y(){function i(e,n){n&&(function(){if(!n.tagName)throw new TypeError("Object is not a valid DOM element");if("IFRAME"!==n.tagName.toUpperCase())throw new TypeError("Expected <IFRAME> tag, found <"+n.tagName+">")}(),d(n,e),o.push(n))}var o;return function(){for(var e=["moz","webkit","o","ms"],n=0;n<e.length&&!r;n+=1)r=window[e[n]+"RequestAnimationFrame"];r?r=r.bind(window):T("setup","RequestAnimationFrame not supported")}(),b(),function(e,n){var t;switch(o=[],(t=e)&&t.enablePublicMethods&&N("enablePublicMethods option has been removed, public methods are now always available in the iFrame"),typeof n){case"undefined":case"string":Array.prototype.forEach.call(document.querySelectorAll(n||"iframe"),i.bind(u,e));break;case"object":i(e,n);break;default:throw new TypeError("Unexpected data type ("+typeof n+")")}return o}}function v(e){e.fn?e.fn.iFrameResize||(e.fn.iFrameResize=function(t){return this.filter("iframe").each(function(e,n){d(n,t)}).end()}):E("","Unable to bind to jQuery, it is not fully loaded.")}"undefined"!=typeof window&&(x="message".length,I=(M="[iFrameSizer]").length,r=window.requestAnimationFrame,g={autoResize:!(t=k=null),bodyBackground:null,bodyMargin:null,bodyMarginV1:8,bodyPadding:null,checkOrigin:!(a=l=!1),inPageLinks:!(F={}),enablePublicMethods:!(f=0),heightCalculationMethod:"bodyOffset",id:"iFrameResizer",interval:32,log:!(m={max:1,scroll:1,bodyScroll:1,documentElementScroll:1}),maxHeight:1/0,maxWidth:1/0,minHeight:0,minWidth:0,mouseEvents:!0,resizeFrom:"parent",scrolling:!1,sizeHeight:!0,sizeWidth:!1,warningTimeout:5e3,tolerance:0,widthCalculationMethod:"scroll",onClose:function(){return!0},onClosed:function(){},onInit:function(){},onMessage:function(){N("onMessage function not defined")},onMouseEnter:function(){},onMouseLeave:function(){},onResized:function(){},onScroll:function(){return!0}},z={},window.jQuery&&v(window.jQuery),"function"==typeof define&&define.amd?define([],y):"object"==typeof module&&"object"==typeof module.exports&&(module.exports=y()),window.iFrameResize=window.iFrameResize||y())}();



MPage.namespace("clinical_office.integration");

clinical_office.functions = function() {};



clinical_office.functions.embed = function(component) {

  var frameId = 'frame' + component.getComponentUid();

  var target = component.getTarget();



  if (component.data.response != undefined) {
    target.innerHTML = '<iframe style="width: 100%" id="' + frameId + '" src="' + component.data.response.url + '" scrolling="no" frameBorder="0"></iframe>';

    $('#' + frameId).iFrameResize({heightCalculationMethod: 'lowestElement'});
  } else {

    target.innerHTML = "<div>An error has occurred.</div>";

  }
}

/* END - Clinical Office Integration */



/* BEGIN - Patient Information Component */

MPage.namespace("phsa_cd.patient_information");


phsa_cd.patient_information = function () {
};


phsa_cd.patient_information.prototype = new MPage.Component();
phsa_cd.patient_information.prototype.constructor = MPage.Component;

phsa_cd.patient_information.prototype.base = MPage.Component.prototype;


phsa_cd.patient_information.prototype.init = function () {

  var component = this;

  var compId = component.getComponentUid();


  component.cclProgram = "1co_mpage_redirect:group1";


	
  // clear cclParams in case of refresh
  component.cclParams = ["component", "patient-information"];

};


phsa_cd.patient_information.prototype.render = function () {

	clinical_office.functions.embed(this);

};


/* END - Patient Information Component */



/* 	********************************************************************************
	START - Prem Infant Hyperbilirubinemia Graph - VB_PREMATUREINFANTHYPERBILIRUB 
	********************************************************************************/
MPage.namespace("phsa_cd.bc_all_mp_prem_infant_graph");

phsa_cd.bc_all_mp_prem_infant_graph = function () {
};
phsa_cd.bc_all_mp_prem_infant_graph.prototype = new MPage.Component();
phsa_cd.bc_all_mp_prem_infant_graph.prototype.constructor = MPage.Component;
phsa_cd.bc_all_mp_prem_infant_graph.prototype.base = MPage.Component.prototype;
phsa_cd.bc_all_mp_prem_infant_graph.data = {};
phsa_cd.bc_all_mp_prem_infant_graph.graphId = '';

phsa_cd.bc_all_mp_prem_infant_graph.prototype.init = function () {
    //code to perform before immediately rendering (usually updating params is needed)
    var component = this;
    var compId = component.getComponentUid();

    component.cclProgram = "bc_all_mp_prem_infant_graph";

    //clear cclParams in case of refresh
    component.cclParams = [];
    component.cclParams.push("MINE");
    component.cclParams.push(this.getProperty("personId"));
    component.cclParams.push(this.getProperty("encounterId"));
    component.cclParams.push(this.getProperty("userId"));
};

phsa_cd.bc_all_mp_prem_infant_graph.prototype.render = function () {
	// Initialize variables
    var component = this;
    var compId = component.getComponentUid();
    var target = component.getTarget();
	var dataQualified = false;
	phsa_cd.bc_all_mp_prem_infant_graph.graphId = 'chart' + compId;
	
	var sHTML = "";

    // Add a triangle to jqPlot
    $.jqplot.pyramidMarkerRenderer = function(options) {
        $.extend(true, this, options);
    };

    $.jqplot.pyramidMarkerRenderer.prototype.init = function(options) {
        $.extend(true, this, options);
    };

    $.jqplot.pyramidMarkerRenderer.prototype.draw = function(ctx, points, options) {
        ctx.save();

        ctx.lineWidth = 1;
        ctx.fillStyle = '#441650';
        ctx.beginPath();
        ctx.moveTo(points[0]-points[2], points[1]+points[2]);
        ctx.lineTo(points[0], points[1]-points[2]);
        ctx.lineTo(points[0]+points[2], points[1]+points[2]);
        ctx.closePath();
        ctx.fill();

        ctx.restore();
    };
    // End of code to add a triangle to jqPlot
	
	if (this.data.response != undefined && this.data.response.status == 'Ready') {
		if (this.data.response.results.length > 0) {
			dataQualified = true;
			phsa_cd.bc_all_mp_prem_infant_graph.data = this.data.response;
		
			// Draw the menu
			sHTML = phsa_cd.bc_all_mp_prem_infant_graph.menu();
		
			// Prepare the layout
			sHTML += '<div style="display: flex; flex-wrap: nowrap;">' +
					'<div style="flex: 2;">' +
					phsa_cd.bc_all_mp_prem_infant_graph.topLegend() +
					'<div id=' + phsa_cd.bc_all_mp_prem_infant_graph.graphId + ' style="min-height: 30em;"> </div>' +
					phsa_cd.bc_all_mp_prem_infant_graph.bottomLegend() + '</div>' +
					'<div style="flex: 1; padding-left: 1rem;">' +
					phsa_cd.bc_all_mp_prem_infant_graph.riskPredictorsChart() +
					phsa_cd.bc_all_mp_prem_infant_graph.phototherapyChart() +					
					'</div></div>';									
						
			// Render the final HTML
			target.innerHTML = sHTML;
			
			// Substitute chart id with JQPlot graph
			phsa_cd.bc_all_mp_prem_infant_graph.renderGraph(0);
		}
		
	} 
	
	if (!dataQualified) {
		target.innerHTML = "<h3>No results qualified</h3>";
	}

};

// Draws the drop-down menu on the screen
phsa_cd.bc_all_mp_prem_infant_graph.menu = function() {
	var menu = phsa_cd.bc_all_mp_prem_infant_graph.data.menu;
	
	var sHTML = '';
	
	if (menu.length > 0) {
		for (m = 0; m < menu.length; m++) {
			sHTML += '<option onclick="phsa_cd.bc_all_mp_prem_infant_graph.renderGraph(' + menu[m].dataSet + ')">' + menu[m].label + '</option>';
		}
		sHTML = '<table style="width: 100%; margin-bottom: 5px; padding-bottom: 3px; border-bottom: 1px solid;"><tr>' + 
				'<td style="white-space: nowrap;"><b>Risk Factors:</b> <select style="width: 150px;">' + sHTML + '</select></td>' + 
				'<td style="padding-left: 0.2rem; color: blue;">' +
				'Select correct graph based on risk factors. Risk factors = isoimmune hemolytic disease, G6PD deficiency, asphyxia, respiratory distress, ' +
				'significant lethargy, temperature instability, sepsis, acidosis.</td>' +
				'</tr></table>';
	}
	
	return sHTML;
}

// Draws the top legend showing the data types displayed in the graph
phsa_cd.bc_all_mp_prem_infant_graph.topLegend = function() {
	var results = phsa_cd.bc_all_mp_prem_infant_graph.data.results;
	var sSerum = '';
	var sTranscutaneous = '';
	for (d = 0; d < results.length; d++) {
		if (results[d].resultType == 'Serum') {
			sSerum = '<div style="display: inline; margin: 0.5rem;"><span style="font-size: 1.75em; color: #0189D5;">&#9679;</span> Serum</div>';
		} else {
			sTranscutaneous = '<div style="display: inline; margin: 0.5rem;"><span style="color: #441650;">&#9650;</span> Transcutaneous</div>';
		}
	}
	return '<div style="position: relative; float: left; top:0; left: 100px;">' + sSerum + sTranscutaneous + '</div><div style="clear: both"></div>';
}

// Draws the bottom legend showing what all the lines represent
phsa_cd.bc_all_mp_prem_infant_graph.bottomLegend  = function() {
	var ref = phsa_cd.bc_all_mp_prem_infant_graph.data.ref;
	var refText = phsa_cd.bc_all_mp_prem_infant_graph.data.refText;
	var sHTML = '';
	for (r = 0; r < ref.length; r++) {
		if (ref[r].dataSet == 0) {
			sHTML += '<li style="display: inline; margin: 0.5rem;"><span style="color: ' +  ref[r].color + '">&#9644;&#9644;&#9644;</span> ' + ref[r].label + '</li>';
		}
	}
	sHTML = '<div style="text-align: center; margin-top: 0.5rem;"><ul style="list-style-type: none;">' + sHTML + '</ul></div>';
	if (refText == 1) {
		sHTML += '<div style="text-align: center; margin-top: 0.5rem; font-size: 0.8em;">Content reproduced from Pillai, A., Pandita, A., Osiovich, H., & Manhas, D. (2020). Pathogenesis and Management of Indirect Hyperbilirubinemia in Preterm Neonates Less Than 35 Weeks: Moving Toward a Standardized Approach. NeoReviews 2020, 21, e298-307. DOI: 10.1542/neo.21-5-e298</div>'
	}
	return sHTML;
}

// Draws Risk Predictors Chart 
phsa_cd.bc_all_mp_prem_infant_graph.riskPredictorsChart= function() {
	var data = phsa_cd.bc_all_mp_prem_infant_graph.data;
	var tStyle = 'padding-right: 0.5rem; padding-left: 0.5rem; border: 1px solid;';
    var style = 'even';
	
	// Risk Predictors Title and table headings
	var sHTML = '<div style="padding-top: 0.5rem;">' + 
					'<h3>Risk Predictor</h3>' +
					'<table style="width: auto;">' +
					'<tr style="border: 1px solid;"><th style="' + tStyle + '">Age</th><th style="' + tStyle + '">Result</th>';
	if (data.combinedResultInd == 1) {
		sHTML += '<th style="' + tStyle + '">Details</th>';
	}	
	sHTML += '<th style="' + tStyle + '">Type</th><th style="' + tStyle + '">Rate of Rise</th></tr>';
	
	// Risk Predictors Table content
	for (d = 0; d < data.results.length; d++) {
	
		// Alternate zebra stripe
		if (style == 'odd') style = 'even'
		else style = 'odd';

		sHTML += '<tr class="' + style + '">' +
				'<td style="' + tStyle + '">' + data.results[d].hours + ' hrs</td>' +
				'<td style="' + tStyle + '">' + data.results[d].result + ' (&micro;mol/L)</td>';
		if (data.combinedResultInd == 1 && data.results[d].displayInd == 1) {
			sHTML += '<td style="' + tStyle + '">' + data.results[d].resultDisplay + '</td>';
		} else if (data.combinedResultInd == 1) {
			sHTML += '<td style="' + tStyle + '">&nbsp;</td>';
		}				
	
		// Draw the graph symbol on the chart
		if (data.results[d].resultType == 'Serum') {
			sHTML +=  '<td style="text-align: center;' + tStyle + '"><span style="font-size: 1.4em; color: #0189D5;">&#9679;</span></td>';
		} else if (data.results[d].resultType == 'Transcutaneous') {
			sHTML +=  '<td style="text-align: center;' + tStyle + '"><span style="color: #441650;">&#9650;</span></td>';
		} else {
			sHTML +=  '<td style="text-align: center;' + tStyle + '"><span style="font-size: 1.4em; color: #0189D5;">&#9679;</span>' + data[d].results.resultType + '</td>';
		}
		
		if (data.results[d].rateOfRise != '') {
			sHTML += '<td style="' + tStyle + '">' + data.results[d].rateOfRise + ' (&micro;mol/L/hr)</td>';
		} else {
			sHTML += '<td style="' + tStyle + '">&nbsp;</td>';
		}
		sHTML += '</tr>';
	
	}
	
	sHTML += '</table></div>';
	
	return sHTML;
}

// Draws Phototherapy & Phototherapy recommendation chart
phsa_cd.bc_all_mp_prem_infant_graph.phototherapyChart= function() {
	var ptActivity = phsa_cd.bc_all_mp_prem_infant_graph.data.ptActivity;
	var sHTML = '';
	var tStyle = 'padding-right: 0.5rem; padding-left: 0.5rem; border: 1px solid;';
    var style = 'even';

	if (ptActivity.length > 0) {
		sHTML += '<div style="padding-top: 0.8rem;"><h3>Phototherapy</h3><table style="width: auto;">' + '<tr><th style="' + tStyle + '">Age</th><th style="' + tStyle + '">Action</th></tr>';

		for (pt = 0; pt < ptActivity.length; pt++) {
			if (style == 'odd') style = 'even'
			else style = 'odd';

			sHTML += '<tr class="' + style + '"><td style="' + tStyle + '">' + ptActivity[pt].hours + ' hrs</td><td style="' + tStyle + '">' + ptActivity[pt].action + '</td></tr>';
		}

		sHTML += '</table></div>';
	}
	
	// Add the Recommendation Chart
	if (phsa_cd.bc_all_mp_prem_infant_graph.data.recommendationChart > 0) {
		sHTML += '<div style="padding-top: 0.8rem;"><table style="width: auto;">' +
                    '<tr><th style="' + tStyle + '">Range</th><th style="' + tStyle + '" colspan="2">Recommendation</th></tr>';

		if (phsa_cd.bc_all_mp_prem_infant_graph.data.recommendationChart == 1) {
			sHTML += '<tr><td style="' + tStyle + '"><b><span style="color:#4472c4">Phototherapy Threshold</span> - <span style="color:#ed7d31">Alert Level 1</span></b></td>' +
                        '<td style="' + tStyle + '">Level 1 Phototherapy</td>' +
                        '<td style="' + tStyle + '">Follow-up Serum Bilirubin at 6-24 hrs</td></tr>'

			sHTML += '<tr><td style="' + tStyle + '"><b><span style="color:#ed7d31">Alert Level 1</span> - <span style="color:#ffd966">Alert Level 2</span></b></td>' +
                        '<td style="' + tStyle + '">Level 2 Phototherapy</td>' +
                        '<td style="' + tStyle + '">Follow-up Serum Bilirubin at 6-12 hrs</td></tr>'

			sHTML += '<tr><td style="' + tStyle + '"><b><span style="color:#ffd966">Alert Level 2</span> - <span style="color:#c00000">Exchange Transfusion Threshold</span></b></td>' +
                        '<td style="' + tStyle + '">Level 3 Phototherapy</td>' +
                        '<td style="' + tStyle + '">Follow-up Serum Bilirubin at 4-12 hrs</td></tr>'
		} else {
			sHTML += '<tr><td style="' + tStyle + '"><b><span style="color:#4472c4">Phototherapy Threshold</span> - <span style="color:#ffc000">Alert Level</span></b></td>' +
                        '<td style="' + tStyle + '">Level 2 Phototherapy</td>' +
                        '<td style="' + tStyle + '">Follow-up Serum Bilirubin at 6-24 hrs</td></tr>'

			sHTML += '<tr><td style="' + tStyle + '"><b><span style="color:#ffc000">Alert Level</span> - <span style="color:#c00000">Exchange Transfusion Threshold</span></b></td>' +
                        '<td style="' + tStyle + '">Level 3 Phototherapy</td>' +
                        '<td style="' + tStyle + '">Follow-up Serum Bilirubin at 4-12 hrs</td></tr>'
		}

		sHTML += '<tr><td style="' + tStyle + '">&nbsp;</td><td style="' + tStyle + '">If the rate of rise is &ge; 8.5&micro;mol/L per hour</td><td style="' + tStyle + '">Start Level 3 Phototherapy: likely suggests hemolysis</td></tr>';
		sHTML += '</table></div>';		
	}	
	
	return sHTML;
}

// Render the graph
phsa_cd.bc_all_mp_prem_infant_graph.renderGraph = function(dataSet) {
	var data = phsa_cd.bc_all_mp_prem_infant_graph.data;
	var graphObj;
	var lines = [];
	var gSeries = [];
	
	var line = [];		// Serum
	var line2 = [];		// Transcutaneous

	// Generate each line of data
	for (d = 0; d < data.results.length; d++) {
		if (data.results[d].resultType == 'Serum') {
			line.push( [ data.results[d].hours, data.results[d].result, data.results[d].resultDisplay ] );
		} else {
			line2.push ( [ data.results[d].hours, data.results[d].result, data.results[d].resultDisplay ] );
		}
	}
	
	if (line.length > 0) {
		lines.push(line);
		gSeries.push({showLine: false, markerOptions: {size: 10, shadow: false, style: "filledCircle"}, color: "#0189D5"});
	}
	if (line2.length > 0) {
		lines.push(line2);
		gSeries.push({showLine: false, markerOptions: {size: 10, shadow: false, shapeRenderer: new $.jqplot.pyramidMarkerRenderer()}, color: "#441650"});
	}
	
	// Add the reference lines
	for (r = 0; r < data.ref.length; r++) {
		if (data.ref[r].dataSet == dataSet) {			// Only show reference ranges for correct data set
			var line = [];
			
			for (l = 0; l < data.ref[r].value.length; l++) {
				line.push( [ (l * data.graphTick), data.ref[r].value[l] ] );
			}
			lines.push(line);
			gSeries.push({lineWidth:1, markerOptions: {size: 1}, color: data.ref[r].color});
		}
	}
	
	// Build the JQPlot object
	graphObj = {
		title: data.graphTitle,
		grid: { backgroundColor: '#ffffff' },
		axes: {
			xaxis: {
				label: 'Postnatal Age (hours)',
				min: 0,
				max: data.graphMax,
				tickInterval: data.graphTick
			},
			yaxis: {
				label: 'Bilirubin (&micro;mol/L)',
				min: data.graphYMin,
				tickInterval: data.graphYInterval,
				tickOptions: {
					formatString: "%d"
				}
			}
		},
		highlighter: {
			show: true,
			tooltipContentEditor: function(str, seriesIndex, pointIndex, plot) {
				if (plot.data[seriesIndex][pointIndex][2]) {
					return ("Age: " + plot.data[seriesIndex][pointIndex][0] + " (hours)  Result: " + plot.data[seriesIndex][pointIndex][2]);
				} else {
					return ("Intersection - Age: " + plot.data[seriesIndex][pointIndex][0] + " (hours)  Result: " + plot.data[seriesIndex][pointIndex][1] + '(&micro;mol/L)');
				}
			},
			tooltipLocation: 'ne',
		},
		series: gSeries
	};
	
	// Render the graph	
	var plotGraph = $.jqplot(phsa_cd.bc_all_mp_prem_infant_graph.graphId, lines, graphObj);
	plotGraph.redraw();

	
	$(window).resize(function() {
		plotGraph.replot({resetAxes: true});
	});
	
}

/* 	********************************************************************************
	END - Prem Infant Hyperbilirubinemia Graph - VB_PREMATUREINFANTHYPERBILIRUB 
	********************************************************************************/
