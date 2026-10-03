{ pkgs, ... }:
{
  # Generate nix-paths.lua — the only Nix-interpolated Lua file.
  # All other Lua files require("nix-paths") to get package paths.
  xdg.configFile."nvim/lua/nix-paths.lua".text = ''
    return {
      -- LSP servers
      rust_analyzer = "${pkgs.rust-analyzer}/bin/rust-analyzer",
      basedpyright = "${pkgs.basedpyright}/bin/basedpyright-langserver",
      nil_ls = "${pkgs.nil}/bin/nil",
      nixpkgs_fmt = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt",
      metals = "${pkgs.metals}/bin/metals",
      typescript_language_server = "${pkgs.typescript-language-server}/bin/typescript-language-server",
      html_language_server = "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server",
      clangd = "${pkgs.llvmPackages_19.clang-tools}/bin/clangd",
      gopls = "${pkgs.gopls}/bin/gopls",
      jdtls = "${pkgs.jdt-language-server}/bin/jdtls",

      -- Formatters
      ruff = "${pkgs.ruff}/bin/ruff",
      stylua = "${pkgs.stylua}/bin/stylua",
      prettier = "${pkgs.prettier}/bin/prettier",

      -- Tools
      ripgrep = "${pkgs.ripgrep}/bin/rg",
      fd = "${pkgs.fd}/bin/fd",
      glow = "${pkgs.glow}/bin/glow",
    }
  '';

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      # theme
      onedark-nvim
      # core
      telescope-nvim
      telescope-ui-select-nvim
      nui-nvim
      nvim-surround
      which-key-nvim
      nvim-tree-lua
      gitsigns-nvim
      conform-nvim
      # completion
      blink-cmp
      # markdown
      render-markdown-nvim
      # editing
      nvim-autopairs
      # commenting is built-in (gc/gcc) since Neovim 0.10
      # icons
      nvim-web-devicons
      mini-nvim
      # statusline
      lualine-nvim
      # treesitter
      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          tsx
          nix
          c
          python
          lua
          scala
          java
          rust
          go
          bash
          json
          sql
          dockerfile
          yaml
          markdown
          vim
          gitignore
          hcl
          http
          terraform
          typescript
          javascript
          html
          css
          scss
          vimdoc
        ]
      ))
      nvim-treesitter-context
      nvim-ts-autotag
      # lsp
      trouble-nvim
      nvim-metals
      nvim-lspconfig
      # navigation
      flash-nvim
      # folding
      nvim-ufo
      promise-async
      # ui
      bufferline-nvim
      nvim-cursorline
      indent-blankline-nvim
      # copilot
      copilot-vim
      # rust
      rustaceanvim
      crates-nvim
      # notify
      nvim-notify
      # references
      vim-illuminate
      # neoclip
      nvim-neoclip-lua
      # git
      vim-fugitive
      # db
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
      # terminal
      toggleterm-nvim
      # markdown preview
      glow-nvim
    ];

    initLua = builtins.concatStringsSep "\n" [
      (builtins.readFile ./which-key.lua)
      (builtins.readFile ./basic.lua)
      (builtins.readFile ./completion.lua)
      (builtins.readFile ./formatters-setup.lua)
      (builtins.readFile ./lsp.lua)
      (builtins.readFile ./filetree.lua)
      (builtins.readFile ./themes/onedark.lua)
      (builtins.readFile ./treesitter.lua)
      (builtins.readFile ./telescope-setup.lua)
      (builtins.readFile ./trouble.lua)
      (builtins.readFile ./gitsigns.lua)
      (builtins.readFile ./fugitive.lua)
      (builtins.readFile ./notify.lua)
      (builtins.readFile ./autopairs.lua)
      (builtins.readFile ./statusline.lua)
      (builtins.readFile ./bufferline.lua)
      (builtins.readFile ./visuals.lua)
      (builtins.readFile ./json.lua)
      (builtins.readFile ./flash.lua)
      (builtins.readFile ./copilot.lua)
      (builtins.readFile ./undotree.lua)
      (builtins.readFile ./neoclip.lua)
      (builtins.readFile ./surround.lua)
      (builtins.readFile ./terminal.lua)
      (builtins.readFile ./markdown.lua)
      (builtins.readFile ./blink-highlight.lua)
      (builtins.readFile ./glow-setup.lua)
    ];
  };

}
