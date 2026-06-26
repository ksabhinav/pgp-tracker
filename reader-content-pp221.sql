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

-- Concerns with Delhi Metro (web article -> in-app reader; reading pp221_lu03_r03)
insert into public.reading_content (url, reading_id, title, kind, content_html, extracted_by, needs_review)
values (
  $rc$https://blog.theleapjournal.org/2018/12/concerns-with-delhi-metro.html$rc$,
  $rc$pp221_lu03_r03$rc$,
  $rc$Concerns with Delhi Metro$rc$,
  'article',
  $html$<p class="reading-byline"><em>Shubho Roy and Ajay Shah · The Leap Blog · 14 December 2018</em></p>
<p>The primary input that goes into an infrastructure project is money. In the case of the Delhi Metro, cost estimates run to Rs.5.52 Billion per km for the underground stretches and Rs.2 Billion per km for the over-ground stretches. The construction cost does not include the cost of land, which the government provides at a subsidised rate.</p>
<p>Turning to the revenues, the arithmetic is clear. The revenue of Delhi Metro comes from the price per ride and the number of rides. To fix intuition, suppose we spend Rs.100 on an asset. Suppose the capital requires annual payments of Rs.10 per year. The infrastructure asset has to then generate at least Rs.10 of cash per year, after paying for the (small) running costs. This cash can come about in many ways, e.g. sell 1 ticket at Rs.10 or sell 10 tickets at Rs.1, and so on.</p>
<p>The cost of capital in India is relatively high, given the presence of high macro/financial risk and a closed capital account. The annual cost of servicing the debt and equity capital, that goes into such projects, will be higher than is the case elsewhere in the world. The costs of building an urban metro system in India are similar to those seen elsewhere in the world. But the same infrastructure asset has to generate a higher revenue stream in India given a higher cost of capital. This means that the user charge or the intensity of use, or both, have to be higher in India.</p>
<p>Hence, to think about the viability of the Delhi Metro, we have to examine the extent to which it beats global benchmarks in user charges or intensity of use or both.</p>
<h3>User Charges</h3>
<p><em>[Chart in the original: user charges across major metro systems]</em></p>
<p>As the graph above shows, Delhi Metro has one of the lowest user charges in the world, when compared with other large metro systems. So we're not getting through on this one.</p>
<h3>Intensity of use</h3>
<p>We could just look at the number of rides in the Delhi Metro. Matters become a little more complicated for international comparisons, as the number of rides varies (slightly) with the length of the metro system. Bigger metro systems get somewhat more rides. To compare apples with apples, we look at how Delhi Metro should have fared in the context of these relationships, as observed worldwide.</p>
<p><em>[Chart in the original: rides per km of track]</em></p>
<p>As the graph above shows, on this metric also, the Delhi Metro fares poorly. Delhi Metro is out of line when compared with the relationship seen worldwide. In this graph, the size of the bubble is proportional to total annual rides. Mumbai's ancient train system is faring well in translating kilometres of track into rides. The old Kolkata Metro also does a pretty good job in generating rides per km of track. But Delhi is not.</p>
<h3>Thus there is a financial problem</h3>
<p>The cost of a metro system in many big cities of the world is similar. The dominant element of this cost is the cost of capital. This is a more significant barrier in India, as the cost of capital is higher in India when compared with most large countries. To make ends meet, a metro system has to achieve the required cash flow by having an adequate user charge multiplied by the number of rides. In Delhi Metro, we are faring poorly on both counts: We don't have an adequate user charge, and we don't have the required number of rides.</p>
<p><em>[Chart in the original: rides per km per year vs average price]</em></p>
<p>As the graph above shows, Delhi fares poorly on both Rides per Km per Year and the average price charged for a commute. The size of the bubble represents the size of the metro system.</p>
<p>Suppose we treat Shanghai as a benchmark. Their charge is similar to that in Delhi, but they get 5.49 million rides per km of track against Delhi's 3.41. There is a gap of about 60%.</p>
<p>How could this gap be closed by holding prices intact? Last year, Delhi's metro system was 296 km long. Delhi would need to get 615.68 million more rides per year without increasing track length, to catch up with Shanghai. That is a 60% rise from Delhi's 2017 ridership of 1007.9 million rides.</p>
<p>Conversely, to obtain the same revenue per km of track, Delhi needs to charge 60% more per ticket. This seems far more feasible.</p>
<p>As Delhi adds more lines next year, the denominator will grow. This will translate into a bigger challenge in terms of obtaining the requisite number of rides.</p>
<h3>Positive externalities</h3>
<p>We could argue that Delhi Metro is all about positive externalities and that we should not be so worried about the lack of revenues. We can then use other means like taxes to pay for the system. In this vision, the essence of urban infrastructure lies in promoting dense interactions between residents. This is measured by counting the rides per capita. A metro system is inducing large positive externalities if it achieves high values of rides per capita per year.</p>
<p><em>[Chart in the original: rides per capita per year]</em></p>
<p>As the evidence above shows, Delhi Metro fares poorly on the rides per capita per year. Delhi is not a small metro system. It now ranks on amongst the top ten metro systems. As the graph shows, in such large systems, the rides per capita should be higher, as the metro network covers the city better.</p>
<p>For an example, Delhi and Madrid are both at about 200 kilometres of line. But in Delhi, there are 25 rides per person per year, while Madrid is at about 100. We are about 4 times worse than we ought to be.</p>
<h3>Conclusions</h3>
<p>To justify infrastructure assets such as Delhi Metro, we in India have to find exceptionally large user charges, given the difficulties of macro/finance policy which impose an elevated cost of capital. Or, to the extent that the direct revenues are inadequate, we have to justify the expenditure based on an externalities argument.</p>
<p>Delhi Metro is faring poorly on all three fronts. The cost per ride is low, i.e. the user charge is inadequate. The number of rides per year is low. The intensity of usage is low. We have a problem.</p>
<p>We conjecture that part of the problem may lie not in Delhi Metro but in Delhi's urban planning. Delhi is a vertically challenged city, with severe restrictions on the number of floors a person can build. This FSI restriction creates large areas of low-density housing. For example, the IIT Delhi Metro Station is bound by IIT Delhi on one side and the Green Belt on the other. IIT Delhi has a student population of less than 8,000 and the Green Belt is entirely uninhabited for a few kilometres. In effect, the IIT Metro Station does not have a catchment area of an adequate number of potential customers.</p>
<hr>
<p><em>The authors would like to thank Vimal Balasubramaniam, Devendra Damle, Ashim Kapoor, and Shalini Mittal for valuable contributions.</em></p>$html$,
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
