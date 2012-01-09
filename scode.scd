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

var tagList, snippetList, addTag, deleteTag, addSnippet, snippet, appliedTags,
	currentTag, currentSnippet;

k= ();

k.tags= Set[\gui, \synthdef, \control];
k.snippets= [];
//k.currentTag= 0;

currentTag= 0;

w= Window("scode", Rect(318, 325, 750, 560)).front;
w.addFlowLayout(10@10, 10@10);

tagList= ListView(w, 130@220)
	.action_{|me|
		currentTag= me.value;
		switch(me.value,
			0, {deleteTag.enabled= false;},
			1, {deleteTag.enabled= true;},
			2, {deleteTag.enabled= true;},
			3, {deleteTag.enabled= true;}
		
		);
	}
	.items_(["= ALL ="] ++ k.tags.asArray.sort);

snippetList= ListView(w, 590@220)
	.action_{|me| };

w.view.decorator.nextLine;

addTag= SmoothButton(w, 20@20)
	.states_([
		[ '+', Color.white, Color.black.alpha_(0.25) ] ])
	.action_{|me|
		SCRequestString(
			"new tag", // default
			"please enter your new tag", // question
			{ |newTag| // action
				k.tags= k.tags.add(newTag.asSymbol);
				tagList.items_(["= ALL ="] ++ k.tags.asArray.sort);
			}
		);
	}
	.focusColor_(Color.clear)
	.radius_(0)
	.border_(1);

deleteTag= SmoothButton(w, 20@20)
	.states_([
		[ '-', Color.white, Color.black.alpha_(0.25) ] ])
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
	.enabled_(false);

w.view.decorator.shift(80, 0);

addSnippet= SmoothButton(w, 20@20)
	.states_([
		[ '+', Color.white, Color.black.alpha_(0.25) ] ])
	.action_{|me|
		SCRequestString(
			"Untitled Snippet", // default
			"Please enter your snippet title", // question
			{ |newSnippetTitle| // action
				// add a new snippet Event
				k.snippets= k.snippets.add(());
				// get the new snippet array size
				x= k.snippets.size;
				currentSnippet= x-1;
				// store the title
				k.snippets[currentSnippet].title= newSnippetTitle;
				// update the snippetList
				snippetList.items= snippetList.items.add(
					k.snippets[currentSnippet].title);
				k.snippets[currentSnippet].snippet= "yes";
				snippet.string_(k.snippets[currentSnippet].snippet);
				// enable the text editor
				snippet.enabled_(true);
				
			}
		);
	}
	.focusColor_(Color.clear)
	.radius_(0)
	.border_(1);

snippet= TextView(w, 730@250)
	.action_{|me| }
	.enabled_(false);

w.view.decorator.nextLine;

appliedTags= Array.fill(k.tags.size, {|i|
	SmoothButton(w, 60@20)
		.states_([
			[ k.tags.asArray[i].asString, Color.black, Color.clear ], 
			[ k.tags.asArray[i].asString, Color.white, Color.black.alpha_(0.25) ] ])
		.action_{|me| }
		.focusColor_(Color.clear)
		.border_(1);
});

	SmoothButton(w, 60@20)
		.states_([
			[ "Add...", Color.black, Color.clear ] ])
		.action_{|me| }
		.focusColor_(Color.clear)
		.border_(1);

)
