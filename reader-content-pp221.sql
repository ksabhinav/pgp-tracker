-- Reader content: make the (HTML-only) reading "The flash mobs of class warfare" readable in-app.
-- Web articles can't be one-click PDF-extracted, so this stores the cleaned article text directly
-- as a kind='article' snapshot. Re-runnable (upsert on the URL primary key).
-- Paste into the Supabase SQL Editor and Run (admin).
insert into public.reading_content (url, reading_id, title, kind, content_html, extracted_by, needs_review)
values (
  $rc$https://www.business-standard.com/article/opinion/nitin-pai-the-flash-mobs-of-class-warfare-111121900036_1.html$rc$,
  $rc$pp221_lu01_r02$rc$,
  $rc$The flash mobs of class warfare$rc$,
  'article',
  $html$<p><em>Political upheavals across the globe indicate people are no longer willing to tolerate hierarchically-organised governments</em></p>
<p class="reading-byline"><em>Nitin Pai · Business Standard · First published 19 December 2011</em></p>
<p>Make no mistake. This year’s political upheavals around the world indicate that our societies have become networked so radically that they now pose fundamental challenges to traditional, hierarchically-organised governments.</p>
<p>If asked to identify the common factor in the dramas from North Africa to Russia, from New York to New Delhi, from Moscow to Myanmar, from London to Guangdong, the first thing that comes to mind is public protests. In each of these contexts, people decided “enough was enough” and came out on the streets to make their presence, power and politics felt.</p>
<p>That still begs the question: why now? Surely, there cannot be some kind of a political influenza virus that is causing this pandemic of uprisings and revolts. Then there is the fact that crowds in different countries are demanding very different things. There is little in common in demanding an end to dictatorship in Egypt, corruption in India, capitalism in the United States, land grabbing in China — and something altogether inexplicable in London. This is a classical class struggle. There is little commonality and co-ordination between protests in different countries. They were not caused by the notorious Foreign Hand, even if it joined in to help later on in the game.</p>
<p>Even the causes that brought people to the streets in 2011 are not new. Mubarak and Gaddafi have been around almost as long as we have had broadcast television in India. Corruption in India did not start with the 2G scam. Washington’s socialisation of Wall Street’s losses is not a new phenomenon. As for land grabs in China, the Party had been doing so for nearly two decades before this September, when the brave villagers of Wukan drove its local functionaries out, starting a face-off with Beijing.</p>
<p>In any of these cases, you would be hard-pressed to find a grievance that is recent. Yet the pressure that had been building for many years found explosive release, in historical terms, all at once. Different people, different countries, different causes — yet all engaged in a similar set of activities within the span of a year. They mobilised quickly, so fast as to take the authorities and the media by surprise. They mobilised without charismatic leaders (India might appear more of an exception to this than it really is). They were clearer on what they were against than what they were for.</p>
<p>While it is extremely hard to explain the unprecedented coincidence of political churning around the world, we do know that the worldwide communications revolution that started in the 1990s is now pervasive, causing individuals to be far deeply and intimately connected to each other. This is not just about people connected to each other on Facebook and Twitter. This is about individuals who can receive an SMS on their mobile phones. There are close to a billion mobile phone users in China, and a slightly smaller number in India. Even if these numbers are overstated, it is a fact that our societies are networked like never before.</p>
<p>What’s this got to do with people turning up on the streets in protest? First, in radically networked societies, it is extremely easy to mobilise large numbers of people. It takes a single text message, missed call or tweet to inform people about the time and place of protests. You can do a Tahrir Square with the same technology and resources used to create a flash mob.</p>
<p>Second, because these mobilisations do not depend on middle-level leaders who gather people on the ground, they are that much harder for the authorities to pre-empt. China’s curbs on internet freedom are the equivalent of putting grass-roots leaders into perpetual preventive custody, but it doesn’t work too well. Netizens and censors are playing a cat-and-mouse game, with the latter trying to wipe out mentions of protest-affected areas as soon as they are published on the internet. That isn’t stopping news, photographs and videos from leaking out. Strangely, the United Progressive Alliance government’s ministers are toying with similar ideas, without knowing how ridiculous and out-of-touch they appear with the realities of networked India.</p>
<p>Third, because these mobilisations take place in a networked fashion, they are many times faster than attempts at counter-mobilisation by hierarchically-structured authorities. This forces the authorities into reactive mode, and often without the appropriate tools to manage mass non-violent protests. The use of force to evict protesters, even if the law allows it, is deeply unpopular and causes greater revulsion among those who watch it on television and YouTube. State authorities end up acting late, using too much force — thereby appearing to lack legitimacy even if they technically have the law on their side.</p>
<p>The upshot is this: the popular legitimacy of today’s hierarchically-structured governments – and the political order they rest on – is under threat in radically networked societies. This is as true for democracies like India and the United States as it is for authoritarian states like China and Russia. One reason the United States emerged on top of the world order is because it had the best political system for post-Enlightenment industrial age societies. It may well be that the nation that best reinvents itself for the information age will have a shot at being the next great superpower.</p>
<hr>
<p><em>The author is a founder and fellow for geopolitics at the Takshashila Institution, an independent networked think tank on strategic affairs.</em></p>$html$,
  'manual',
  false
)
on conflict (url) do update
  set reading_id   = excluded.reading_id,
      title        = excluded.title,
      kind         = excluded.kind,
      content_html = excluded.content_html,
      extracted_by = excluded.extracted_by,
      needs_review = excluded.needs_review,
      captured_at  = now();
