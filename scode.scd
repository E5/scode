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

var tagList, titleList, addTag, addSnippet, snippet, appliedTags;

k= ();
k.tags= [\gui, \synthdef, \control];

w= Window("scode", Rect(318, 325, 750, 560)).front;
w.addFlowLayout(10@10, 10@10);

tagList= ListView(w, 130@220)
	.action_{|me| }
	.items_(["= ALL ="]++k.tags);

titleList= ListView(w, 590@220)
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
				tagList.items_(["= ALL ="]++k.tags);
			}
		);
	}
	.focusColor_(Color.clear)
	.radius_(0)
	.border_(1);

w.view.decorator.shift(110, 0);

addSnippet= SmoothButton(w, 20@20)
	.states_([
		[ '+', Color.white, Color.black.alpha_(0.25) ] ])
	.action_{|me|
		SCRequestString(
			"Untitled Snippet", // default
			"Please enter your snippet title", // question
			{ |newSnippetTitle| // action
			}
		);
//		x = SCModalSheet(w, 380@70);
//		SCButton(x, Rect(20,20,340,30))
//			.states_([
//				["Dismiss me", Color.black, Color.red]
//			])
//			.onClose_({"Dismissed!".postln})
//			.action_({ x.close });
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
			[ k.tags[i].asString, Color.black, Color.clear ], 
			[ k.tags[i].asString, Color.white, Color.black.alpha_(0.25) ] ])
		.action_{|me| }
		.focusColor_(Color.clear)
		.border_(1);
});

)
