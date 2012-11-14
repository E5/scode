(
/*******************************************************************************

scode

A utility for storing snippets of SC code. Uses tags for categorising. All code,
tags and other information is stored in a big saveable Dictionary.

Each entry in the snippet table should contain these fields:

Title, Date, Author, Taglist, Snippet

There will be a separate tags table that updates a list of all tags as they are
added. This will enable the user to add a tag without necessarily assigning it
to a snippet.

*******************************************************************************/

var	gui_tagList, gui_snippetList, gui_addTag, gui_deleteTag, gui_addSnippet, gui_snippetInfo, gui_snippet, appliedTags,
currentTag, currentSnippet, updateTagButtons, snippetAddTag, snippetHeader,
saveAll, archivePath, archiveFile;

archivePath= (thisProcess.nowExecutingPath.dirname ++ "/archiveTest.scarc").standardizePath;

if (File.exists(archivePath),
	{
		archiveFile= ZArchive.read(archivePath);
		~archive= archiveFile.readItem(Event);
		// k= archiveFile.readItem(Event);
		archiveFile.close;
		"Archive exists.".postln;
	},{
		~archive= ();
		~archive.tags= Set[];
		~archive.snippets= [];
		// k= ();
		// k.tags= Set[];
		// k.snippets= [];
	}
);

currentTag= 0;

w= Window("scode", Rect(318, 325, 750, 640)).front;
w.addFlowLayout(10@10, 10@10);
// w.minSize_(Size.new(200, 200));

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
.items_(["= ALL ="] ++ ~archive.tags.asArray.sort)
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
			~archive.tags= ~archive.tags.add(newTag);
			gui_tagList.items_(["= ALL ="] ++ ~archive.tags.asArray.sort);
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
			// x= ~archive.snippets.size;
			// currentSnippet= x-1;

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
			snippetAddTag.enabled_(true);
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

// w.view.decorator.nextLine;
//
// snippetHeader= CompositeView(w, 730@50)
// .background_(Color.grey(0.9));
// snippetHeader.addFlowLayout(10@10, 10@10);
//
// SmoothButton(snippetHeader, 710@20)
// .states_([[ \none, Color.white, Color.clear ] ])
// .action_{|me| }
// .focusColor_(Color.white)
// // .focusColor_(Color.clear)
// .radius_(0)
// .border_(0)
// .enabled_(true);
//
// snippetHeader.decorator.reset;
//
// StaticText(snippetHeader, 610@20)
// .string_("XxX")
// // .background_(Color.red)
// .font_(Font( Font.defaultSansFace, 16 ).boldVariant);
//
// w.view.decorator.shift(0, -9);

gui_snippet= TextView(w, 730@300)
.action_{|me| /*me.value.postln;*/ }
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

snippetAddTag= SmoothButton(w, 60@20)
.states_([ [ "Add...", Color.black, Color.clear ] ])
.action_{|me|
	SCRequestString(
		"new tag",
		"please enter your new tag",
		{ |newTag|
			~archive.snippets[currentSnippet].tags.add(newTag);
			updateTagButtons.value(currentSnippet);
		}
	);
}
.focusColor_(Color.clear)
.border_(1)
.enabled_(false)
.resize_(7);

updateTagButtons= {|snippet|
	// remove existing buttons
	appliedTags.do{|item, i|
		item.remove;
		w.refresh;
	};

	w.view.decorator.reset.shift(70, 520);

	// collect the current snippet's tags
	// build the tag buttons array
	appliedTags= Array.fill(
		~archive.snippets[snippet].tags.size,
		{|i|
			SmoothButton(w, 60@20)
			.states_([
				[~archive.snippets[snippet].tags.asArray[i], Color.black, Color.clear ],
				[~archive.snippets[snippet].tags.asArray[i], Color.white, Color.black.alpha_(0.25)]
			])
			.action_{|me| }
			.focusColor_(Color.clear)
			.border_(1);
		}
	);

};

w.view.decorator.nextLine;

saveAll= SmoothButton(w, 100@20)
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
