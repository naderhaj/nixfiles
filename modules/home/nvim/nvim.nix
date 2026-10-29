{ config, pkgs, ... }:
{
  # Linked to the checkout, not copied to the store: Lua edits apply on nvim
  # restart without a rebuild. init.lua (the require list) still needs a switch.
  xdg.configFile."nvim/lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nixfiles/modules/home/nvim/lua";

  programs.neovim = {
    enable = true;
    # On nvim's PATH only (appended, so a project dev shell's version wins).
    # Lua refers to these by bare command name.
    extraPackages = with pkgs; [
      # LSP servers
      rust-analyzer
      basedpyright
      nil
      typescript-language-server
      vscode-langservers-extracted
      llvmPackages_19.clang-tools
      gopls
      jdt-language-server
      yaml-language-server
      helm-ls
      terraform-ls
      # Formatters
      nixfmt
      ruff
      stylua
      prettier
      # Tools
      ripgrep
      fd
      glow
    ];
    plugins = with pkgs.vimPlugins; [
      # theme
      onedark-nvim
      # core
      telescope-nvim
      telescope-ui-select-nvim
      telescope-fzf-native-nvim # fzf sorter: 'exact ^prefix suffix$ !negate
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
          helm
          haskell
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
      SchemaStore-nvim # JSON/YAML schemas (GitHub Actions, compose, Chart.yaml, ...)
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
      # haskell (HLS itself comes from each project's dev shell)
      haskell-tools-nvim
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
      # github PR review
      octo-nvim
      # db
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
      # terminal
      toggleterm-nvim
      # markdown preview
      glow-nvim
    ];

    initLua = ''
      -- nvim-metals needs the metals built against our JRE, or it installs its own via coursier
      vim.g.nix_metals_path = "${pkgs.unstable.metals.override { jre = pkgs.jre; }}/bin/metals"
    ''
    + builtins.readFile ./init.lua;
  };

}
