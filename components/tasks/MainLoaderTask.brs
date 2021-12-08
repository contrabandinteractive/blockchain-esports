
' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "loadConfigSecond"
end sub



Function loadConfigSecond() as Object
    arr = [
'##### Format for inputting stream info #####
'## For each channel, enclose in brackets ##
'{
'   Title: Channel Title
'   streamFormat: Channel stream type (ex. "hls", "ism", "mp4", etc..)
'   Logo: Channel Logo (ex. "http://Roku.com/Roku.jpg)
'   Stream: URL to stream (ex. http://hls.Roku.com/talks/xxx.m3u8)
'}

{
    Title: "Roku Example One"
    streamFormat: "hls"
    Logo: "https://placeholdit.imgix.net/~text?txtsize=33&txt=channel+logo&w=267&h=150"
    Stream: "https://live3-slivertv.akamaized.net/hls/live/2016046/hls_streamer_us_east_0097/playlist.m3u8"
}
{
    Title: "Roku Example Two"
    streamFormat: "hls"
    Logo: "https://placeholdit.imgix.net/~text?txtsize=33&txt=channel+logo&w=267&h=150"
    Stream: "https://live1-slivertv.akamaized.net/hls/live/2015789/hls_streamer_us_west_0097/playlist.m3u8"
}
{
    Title: "Roku Example Three"
    streamFormat: "mp4"
    Logo: "https://placeholdit.imgix.net/~text?txtsize=33&txt=channel+logo&w=267&h=150"
    Stream: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
}
{
    Title: "Roku Example Four"
    streamFormat: "mp4"
    Logo: "https://placeholdit.imgix.net/~text?txtsize=33&txt=channel+logo&w=267&h=150"
    Stream: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
}
{
    Title: "Roku Example Five"
    streamFormat: "mp4"
    Logo: "https://placeholdit.imgix.net/~text?txtsize=33&txt=channel+logo&w=267&h=150"
    Stream: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
}
{
    Title: "Roku Example Six"
    streamFormat: "mp4"
    Logo: "https://placeholdit.imgix.net/~text?txtsize=33&txt=channel+logo&w=267&h=150"
    Stream: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
}



'##### Make sure all Channel content is above this line #####
    ]
    return arr
End Function


sub GetContent()
    ' request the content feed from the API
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    'xfer.SetURL("https://jonathanbduval.com/roku/feeds/roku-developers-feed-v1.json")
    xfer.SetURL("https://jinn.rocks/apps/animalscams/animalcams.json")
    'xfer.SetURL("pkg://feed/animalcams.json")
    rsp = xfer.GetToString()
    rootChildren = []
    rows = {}

    ' parse the feed and build a tree of ContentNodes to populate the GridView
    json = ParseJson(rsp)
    if json <> invalid
        for each category in json
            value = json.Lookup(category)
            if Type(value) = "roArray" ' if parsed key value having other objects in it
                if category <> "series" ' ignore series for this phase
                    row = {}
                    row.title = category
                    row.children = []
                    for each item in value ' parse items and push them to row
                        itemData = GetItemData(item)
                        row.children.Push(itemData)
                    end for
                    rootChildren.Push(row)
                end if
            end if
        end for
        ' set up a root ContentNode to represent rowList on the GridScreen
        contentNode = CreateObject("roSGNode", "ContentNode")
        contentNode.Update({
            children: rootChildren
        }, true)
        ' populate content field with root content node.
        ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment
        m.top.content = contentNode
    end if
end sub

function GetItemData(video as Object) as Object
    item = {}
    ' populate some standard content metadata fields to be displayed on the GridScreen
    ' https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md
    if video.longDescription <> invalid
        item.description = video.longDescription
    else
        item.description = video.shortDescription
    end if
    item.hdPosterURL = video.thumbnail
    item.title = video.title
    item.releaseDate = video.releaseDate
    item.id = video.id
    if video.content <> invalid
        ' populate length of content to be displayed on the GridScreen
        item.length = video.content.duration
        ' populate meta-data for playback
        item.url = video.content.videos[0].url
        item.streamFormat = video.content.videos[0].videoType
    end if
    return item
end function
