function copyToClipboard() {
  var childs = document.getElementById(this.parentElement.parentElement.id)
    .childNodes;
  for (var i = 0; i < childs.length; i++) {
    if (childs[i].className == "text_box") {
      childs[i].select();
      document.execCommand("copy");
    }
  }
}

function setButtonEvents() {
  var buttons = document.getElementsByTagName("button");
  for (var i = 0; i < buttons.length; i++) {
    if (buttons[i].name != "download") {
      buttons[i].addEventListener("click", copyToClipboard);
    }
  }
}

function textAreaAdjust() {
  var textareas = document.getElementsByTagName("textarea");
  for (var n = 0; n < textareas.length; n++) {
    textareas[n].style.height = "1px";
    textareas[n].style.height = 0 + textareas[n].scrollHeight + "px";
  }
}

function getClipboardButton() {
  // copy to clipboard button
  var buttonClipboard = document.createElement("button");
  buttonClipboard.name = "copyToClipboard";
  buttonClipboard.id = "text_box";
  buttonClipboard.onclick = "copyToClipboard()";
  var copyIcon = document.createElement("span");
  copyIcon.classList.add("button_icon");
  copyIcon.innerHTML = "⎘";
  buttonClipboard.appendChild(copyIcon);
  buttonClipboard.appendChild(document.createTextNode(" COPY TO CLIPBOARD"));

  return buttonClipboard;
}

function getLinkButton() {
  // copy link button
  var buttonLink = document.createElement("button");
  buttonLink.name = "copyLink";
  buttonLink.id = "text_box";
  buttonLink.onclick = "copyToClipboard()";
  var copyIcon = document.createElement("span");
  copyIcon.classList.add("button_icon");
  copyIcon.innerHTML = "⎘";
  buttonLink.appendChild(copyIcon);
  buttonLink.appendChild(document.createTextNode(" COPY LINK"));

  return buttonLink;
}

function getDownloadButton(url) {
  // download button
  var link = document.createElement("a");
  link.href = url;
  link.download = url;

  var buttonDownload = document.createElement("button");
  buttonDownload.name = "download";
  buttonDownload.id = "text_box";
  var downloadIcon = document.createElement("span");
  downloadIcon.classList.add("button_icon");
  downloadIcon.innerHTML = "⬇";
  buttonDownload.appendChild(downloadIcon);
  buttonDownload.appendChild(document.createTextNode(" DOWNLOAD"));

  link.appendChild(buttonDownload);

  return link;
}

function appendContent() {
  // run all that when DOM is ready
  document.addEventListener("DOMContentLoaded", function() {
    // checking if projectDetails exists
    if (typeof projectDetails !== "undefined") {
      // creating a conteiner for the whole shabang
      var conteiner = document.createElement("div");
      conteiner.classList.add("conteiner");
      document.body.append(conteiner);

      // press kit label
      var pressKit = document.createElement("h2");
      pressKit.innerHTML = "PRESS KIT";
      conteiner.append(pressKit);

      // title section
      if (typeof projectDetails.title !== "undefined") {
        var title = document.createElement("h1");
        title.innerHTML = projectDetails.title;
        conteiner.append(title);

        document.title = projectDetails.title + " :: PRESS KIT";
      }

      // subtitle section
      if (typeof projectDetails.subTitle !== "undefined") {
        var subTitle = document.createElement("div");
        subTitle.innerHTML = projectDetails.subTitle;
        subTitle.classList.add("subtitle");
        conteiner.append(subTitle);
      }

      // link section
      if (typeof projectDetails.link !== "undefined") {
        var link = document.createElement("div");
        link.classList.add("section");
        link.id = "link";
        conteiner.append(link);

        var linkTitle = document.createElement("div");
        linkTitle.classList.add("section_title");
        linkTitle.innerHTML = "🖥 Link to project";
        link.append(linkTitle);

        var linkButtons = document.createElement("div");
        linkButtons.classList.add("buttons");
        link.append(linkButtons);

        linkButtons.append(getClipboardButton());

        var linkTextArea = document.createElement("textarea");
        linkTextArea.readOnly = true;
        linkTextArea.classList.add("text_box");
        linkTextArea.append(projectDetails.link);
        link.append(linkTextArea);
      }

      // creators section
      if (typeof projectDetails.creators !== "undefined") {
        var creators = document.createElement("div");
        creators.classList.add("section");
        creators.id = "creators";
        conteiner.append(creators);

        var creatorsTitle = document.createElement("div");
        creatorsTitle.classList.add("section_title");
        creatorsTitle.innerHTML = "👩‍💻 Creators";
        creators.append(creatorsTitle);

        var creatorsButtons = document.createElement("div");
        creatorsButtons.classList.add("buttons");
        creators.append(creatorsButtons);

        creatorsButtons.append(getClipboardButton());

        var creatorsTextArea = document.createElement("textarea");
        creatorsTextArea.readOnly = true;
        creatorsTextArea.classList.add("text_box");
        creators.append(creatorsTextArea);

        var creatorsArray = projectDetails.creators;
        for (var i = 0; i < creatorsArray.length; i++) {
          if (i > 0) {
            creatorsTextArea.append("\n");
            creatorsTextArea.append("\n");
          }

          if (typeof creatorsArray[i].name !== "undefined") {
            creatorsTextArea.append("Name: " + creatorsArray[i].name);
          }

          if (typeof creatorsArray[i].portfolio !== "undefined") {
            creatorsTextArea.append("\n");
            creatorsTextArea.append("Portfolio: " + creatorsArray[i].portfolio);
          }

          if (typeof creatorsArray[i].email !== "undefined") {
            creatorsTextArea.append("\n");
            creatorsTextArea.append("Email: " + creatorsArray[i].email);
          }

          if (typeof creatorsArray[i].twitter !== "undefined") {
            creatorsTextArea.append("\n");
            creatorsTextArea.append("Twitter: " + creatorsArray[i].twitter);
          }
        }
      }

      // about section
      if (typeof projectDetails.about !== "undefined") {
        var about = document.createElement("div");
        about.classList.add("section");
        about.id = "about";
        conteiner.append(about);

        var aboutTitle = document.createElement("div");
        aboutTitle.classList.add("section_title");
        var aboutTitleText;
        if (typeof projectDetails.title !== "undefined") {
          aboutTitleText = "🛋 About " + projectDetails.title;
        } else {
          aboutTitleText = "🛋 About";
        }
        aboutTitle.innerHTML = aboutTitleText;
        about.append(aboutTitle);

        var aboutButtons = document.createElement("div");
        aboutButtons.classList.add("buttons");
        about.append(aboutButtons);

        aboutButtons.append(getClipboardButton());

        var aboutTextArea = document.createElement("textarea");
        aboutTextArea.readOnly = true;
        aboutTextArea.classList.add("text_box");
        for (var a = 0; a < projectDetails.about.length; a++) {
          if (a > 0) {
            aboutTextArea.append("\n");
            aboutTextArea.append("\n");
          }
          aboutTextArea.append(projectDetails.about[a]);
        }
        about.append(aboutTextArea);
      }

      // videos section
      if (typeof projectDetails.videos !== "undefined") {
        var videos = document.createElement("div");
        videos.classList.add("section");
        videos.id = "videos";
        conteiner.append(videos);

        var videosTitle = document.createElement("div");
        videosTitle.classList.add("section_title");
        videosTitle.innerHTML = "📹 Videos";
        videos.append(videosTitle);

        for (var v = 0; v < projectDetails.videos.length; v++) {
          var video = document.createElement("div");
          video.classList.add("video");
          video.id = "video" + v;
          videos.append(video);

          if (typeof projectDetails.videos[v].videoPage !== "undefined") {
            var buttons = document.createElement("div");
            buttons.classList.add("buttons");
            video.append(buttons);

            buttons.append(getLinkButton());

            var textArea = document.createElement("textarea");
            textArea.readOnly = true;
            textArea.classList.add("text_box");
            textArea.append(projectDetails.videos[v].videoPage);
            video.append(textArea);
          }

          if (typeof projectDetails.videos[v].embedUrl !== "undefined") {
            var videoFrame = document.createElement("iframe");
            videoFrame.src = projectDetails.videos[v].embedUrl;
            videoFrame.frameBorder = "0";
            videoFrame.width = "100%";
            videoFrame.height = "270";
            video.append(videoFrame);
          }
        }
      }

      // gifs section
      if (typeof projectDetails.gifs !== "undefined") {
        var gifs = document.createElement("div");
        gifs.classList.add("section");
        gifs.id = "videos";
        conteiner.append(gifs);

        var gifsTitle = document.createElement("div");
        gifsTitle.classList.add("section_title");
        gifsTitle.innerHTML = "👾 GIFs";
        gifs.append(gifsTitle);

        for (var g = 0; g < projectDetails.gifs.length; g++) {
          var gif = document.createElement("div");
          gif.classList.add("gif");
          gif.id = "gif" + g;
          gifs.append(gif);

          if (typeof projectDetails.gifs[g].gifUrl !== "undefined") {
            var btns = document.createElement("div");
            btns.classList.add("buttons");
            gif.append(btns);

            btns.append(getDownloadButton(projectDetails.gifs[g].gifUrl));
            btns.append(getLinkButton());

            var gifTextArea = document.createElement("textarea");
            gifTextArea.readOnly = true;
            gifTextArea.classList.add("text_box");
            gifTextArea.append(projectDetails.gifs[g].gifUrl);
            gif.append(gifTextArea);

            var img = document.createElement("img");
            img.src = projectDetails.gifs[g].gifUrl;
            img.style.width = "100%";
            gif.append(img);
          }
        }
      }

      // photos section
      if (typeof projectDetails.photos !== "undefined") {
        var photos = document.createElement("div");
        photos.classList.add("section");
        photos.id = "videos";
        conteiner.append(photos);

        var photosTitle = document.createElement("div");
        photosTitle.classList.add("section_title");
        photosTitle.innerHTML = "📷 Photos";
        photos.append(photosTitle);

        for (var p = 0; p < projectDetails.photos.length; p++) {
          var photo = document.createElement("div");
          photo.classList.add("photo");
          photo.id = "photo" + p;
          photos.append(photo);

          if (typeof projectDetails.photos[p].photoUrl !== "undefined") {
            var photoBtns = document.createElement("div");
            photoBtns.classList.add("buttons");
            photo.append(photoBtns);

            photoBtns.append(
              getDownloadButton(projectDetails.photos[p].photoUrl)
            );
            photoBtns.append(getLinkButton());

            var photoTextArea = document.createElement("textarea");
            photoTextArea.readOnly = true;
            photoTextArea.classList.add("text_box");
            photoTextArea.append(projectDetails.photos[p].photoUrl);
            photo.append(photoTextArea);

            var photoImg = document.createElement("img");
            photoImg.src = projectDetails.photos[p].photoUrl;
            photoImg.style.width = "100%";
            photo.append(photoImg);
          }
        }
      }
      // footer
      if (typeof projectDetails.footer !== "undefined") {
        let footer = document.createElement("footer");
        let footerLink = document.createElement("a");
        footerLink.href = projectDetails.footer[0].footerLink;
        footerLink.text = projectDetails.footer[0].footerText;
        footer.append(footerLink);
        conteiner.append(footer);
      }
    }

    textAreaAdjust();
    setButtonEvents();
  });
}

appendContent();
