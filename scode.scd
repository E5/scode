(

var	gui_tagList, gui_snippetList, gui_addTag, gui_deleteTag, gui_addSnippet, gui_snippetInfo, gui_snippet, gui_appliedTags,
currentTag, currentSnippet, updateTagButtons, gui_snippetAddTag, snippetHeader,
gui_saveAll, archivePath, archiveFile;

archivePath= (thisProcess.nowExecutingPath.dirname ++ "/archiveTest.scarc").standardizePath;

if (File.exists(archivePath),
	{
		archiveFile= ZArchive.read(archivePath);
		~archive= archiveFile.readItem(Event);
		archiveFile.close;
		"Archive exists.".postln;
	},{
		~archive= ();
		~archive.tagList= Set[];
		~archive.snippets= [];
	}
);

currentTag= 0;

w= Window("scode", Rect(318, 325, 750, 640)).front;
w.addFlowLayout(10@10, 10@10);

gui_tagList= ListView(w, 140@220)
.action_{|me|
	currentTag= me.value;
	// switch(me.value,
	// 	0, {gui_deleteTag.enabled= false;},
	// 	1, {gui_deleteTag.enabled= true;},
	// 	2, {gui_deleteTag.enabled= true;},
	// 	3, {gui_deleteTag.enabled= true;}
	// );
}
.items_(["= ALL ="] ++ ~archive.tagList.asArray.sort)
.resize_(1);

gui_snippetList= ListView(w, 580@220)
.action_{|me|
	currentSnippet= me.value;
	gui_snippet.string= ~archive.snippets[currentSnippet].snippet;
	updateTagButtons.value(currentSnippet);
}
.items_(~archive.snippets.collect({|item, i| item.title}).sort)
.resize_(2);

w.view.decorator.nextLine;

gui_addTag= SmoothButton(w, 20@20)
.states_([
	[ '+', Color.white, Color.black.alpha_(0.25) ] ])
.action_{|me|
	SCRequestString(
		"new tag",
		"please enter your new tag",
		{ |newTag|
			~archive.tagList= ~archive.tagList.add(newTag);
			gui_tagList.items_(["= ALL ="] ++ ~archive.tagList.asArray.sort);
			// w.refresh;
		}
	);
}
.focusColor_(Color.clear)
.radius_(0)
.border_(1)
.enabled_(false)
.resize_(1);

gui_deleteTag= SmoothButton(w, 20@20)
.states_([ [ '-', Color.white, Color.black.alpha_(0.25) ] ])
.action_{|me|
	SCAlert(
		"Are you sure?\nThis will remove this tag from all snippets",
		[ "cancel", "ok" ],
		[{0.postln;}, {1.postln;}],
		background: Color.clear
	);
}
.focusColor_(Color.clear)
.radius_(0)
.border_(1)
.enabled_(false)
.resize_(1);

w.view.decorator.shift(90, 0);

gui_addSnippet= SmoothButton(w, 20@20)
.states_([ [ '+', Color.white, Color.black.alpha_(0.25) ] ])
.action_{|me|
	SCRequestString(
		"Untitled Snippet",
		"Please enter your snippet title",
		{ |newSnippetTitle|

			// add a new snippet Event
			~archive.snippets= ~archive.snippets.add(());

			// get the new snippet array size
			currentSnippet= ~archive.snippets.size -1;

			// store the title
			~archive.snippets[currentSnippet].title= newSnippetTitle;

			// make space for Tags
			~archive.snippets[currentSnippet].tags= Set[];

			// update the gui_snippetList
			gui_snippetList.items= ~archive.snippets.collect({|item, i| item.title}).sort;
			gui_snippetList.value= currentSnippet;
			gui_snippet.font_(Font("HelveticaNeue-Italic", 14));
			gui_snippet.stringColor_(Color.grey);

			// put default text into the new snippet
			~archive.snippets[currentSnippet].snippet= "empty snippet";
			gui_snippet.string_(~archive.snippets[currentSnippet].snippet);

			// enable the text editor
			gui_snippet.enabled_(true);

			// enable the snippet's Add Tag button
			gui_snippetAddTag.enabled_(true);
		}
	);
}
.focusColor_(Color.clear)
.radius_(0)
.border_(1)
.resize_(1);

w.view.decorator.shift(530, 0);

gui_snippetInfo= SmoothButton(w, 20@20)
.states_([ [ 'i', Color.white, Color.blue.alpha_(0.25) ] ])
.action_{|me| }
.focusColor_(Color.clear)
.border_(1)
.enabled_(false)
.resize_(3);

gui_snippet= TextView(w, 730@300)
.action_{|me| }
.hasVerticalScroller_(true)
.hasHorizontalScroller_(true)
.autohidesScrollers_(true)
.enabled_(false)
.usesTabToFocusNextView_(false)
.mouseUpAction_({|me, x, y, modifiers, buttonNumber, clickCount, pos|
	if (me.string == "empty snippet",
		{
			me.string= "";
			me.stringColor_(Color.black);
			me.font_(Font(Font.defaultMonoFace, 9));
		},{
			me.syntaxColorize;
			~archive.snippets[currentSnippet].snippet_(me.string);
		}
	);
})
.resize_(5);

w.view.decorator.nextLine;

gui_snippetAddTag= SmoothButton(w, 60@20)
.states_([ [ "Add...", Color.black, Color.clear ] ])
.action_{|me|
	SCRequestString(
		"new tag",
		"please enter your new tag",
		{ |newTag|
			~archive.snippets[currentSnippet].tags.add(newTag);
			updateTagButtons.value(currentSnippet);
			~archive.tagList= ~archive.tagList.add(newTag);
			gui_tagList.items_(["= ALL ="] ++ ~archive.tagList.asArray.sort);
		}
	);
}
.focusColor_(Color.clear)
.border_(1)
.enabled_(false)
.resize_(7);

updateTagButtons= {|snippet|
	// remove existing buttons
	gui_appliedTags.do{|item, i|
		item.remove;
		w.refresh;
	};

	w.view.decorator.reset.shift(70, 570);

	// collect the current snippet's tags
	// build the tag buttons array
	gui_appliedTags= Array.fill(
		~archive.snippets[snippet].tags.size,
		{|i|
			SmoothButton(w, 60@20)
			.states_([
				[~archive.snippets[snippet].tags.asArray[i], Color.black, Color.clear ],
				[~archive.snippets[snippet].tags.asArray[i], Color.white, Color.black.alpha_(0.25)]
			])
			.action_{|me| }
			.focusColor_(Color.clear)
			.border_(1)
			.resize_(7);
		}
	);

};

w.view.decorator.nextLine;

gui_saveAll= SmoothButton(w, 100@20)
.states_([ [ "Save All..." ] ])
.action_{|me|
	archiveFile= ZArchive.write(archivePath);
	archiveFile.writeItem(~archive);
	archiveFile.writeClose;
}
.focusColor_(Color.clear)
.border_(1)
.resize_(7);

)
